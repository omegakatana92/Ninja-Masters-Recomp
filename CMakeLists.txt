cmake_minimum_required(VERSION 3.21)
project(ninjamas VERSION 0.1.0 LANGUAGES C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# The neogeorecomp toolkit: the in-tree copy (a submodule in a clean
# checkout), or a checkout next to this project.
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/neogeorecomp/CMakeLists.txt)
    set(ng_default ${CMAKE_CURRENT_SOURCE_DIR}/neogeorecomp)
else()
    set(ng_default ${CMAKE_CURRENT_SOURCE_DIR}/../neogeorecomp)
endif()
set(NEOGEORECOMP_DIR ${ng_default} CACHE PATH "neogeorecomp checkout")
add_subdirectory(${NEOGEORECOMP_DIR} neogeorecomp_build)

# Your unzipped MAME "ninjamas" set and "neogeo" system ROMs.  Without it the
# player builds interpreter-only.
set(NINJAMAS_ROM_DIR "" CACHE PATH "Directory with your ninjamas and Neo Geo BIOS ROM files")
# Optional: entry points a previous run found at runtime (--dump-misses).
set(NINJAMAS_ENTRIES "${CMAKE_BINARY_DIR}/entries.txt" CACHE FILEPATH "Extra entry points for the recompiler")

# Stage 1: the generator.
add_executable(ninjamas_recomp src/recomp_main.c src/game.c)
target_link_libraries(ninjamas_recomp PRIVATE m68krecomp_core)
target_include_directories(ninjamas_recomp PRIVATE src)

# Stage 2: the player, with the generated C when ROMs are available.
set(GAME_SOURCES src/main.c)
set(GEN_DIR ${CMAKE_BINARY_DIR}/generated)
set(GEN_FILES 16)
if(NINJAMAS_ROM_DIR)
    set(GEN_SOURCES ${GEN_DIR}/recomp_table.c)
    math(EXPR last "${GEN_FILES} - 1")
    foreach(i RANGE ${last})
        if(i LESS 10)
            list(APPEND GEN_SOURCES ${GEN_DIR}/recomp_0${i}.c)
        else()
            list(APPEND GEN_SOURCES ${GEN_DIR}/recomp_${i}.c)
        endif()
    endforeach()
    # The entry list starts empty; the `profile` target fills it from a
    # scripted play session and the next build regenerates with it.
    if(NOT EXISTS ${NINJAMAS_ENTRIES})
        file(WRITE ${NINJAMAS_ENTRIES} "")
    endif()
    file(MAKE_DIRECTORY ${GEN_DIR})
    add_custom_command(
        OUTPUT ${GEN_SOURCES} ${GEN_DIR}/recomp_common.h
        COMMAND ninjamas_recomp --rom-path ${NINJAMAS_ROM_DIR} --out ${GEN_DIR} --files ${GEN_FILES}
                --entries ${NINJAMAS_ENTRIES}
        DEPENDS ninjamas_recomp ${NINJAMAS_ENTRIES}
        COMMENT "Recompiling Ninja Master's from ${NINJAMAS_ROM_DIR}")
    list(APPEND GAME_SOURCES ${GEN_SOURCES})
endif()

add_executable(ninjamas ${GAME_SOURCES} src/game.c)
set_target_properties(ninjamas PROPERTIES OUTPUT_NAME "Ninjamasters")
target_link_libraries(ninjamas PRIVATE neogeorecomp)
target_include_directories(ninjamas PRIVATE src ${GEN_DIR})
if(NINJAMAS_ROM_DIR)
    add_custom_target(profile
        COMMAND ninjamas --headless --rom-path ${NINJAMAS_ROM_DIR} --frames 6000 --dump-misses ${NINJAMAS_ENTRIES}
        COMMAND ninjamas --headless --rom-path ${NINJAMAS_ROM_DIR} --frames 19000
                --input ${CMAKE_CURRENT_SOURCE_DIR}/tests/play_long.txt --dump-misses ${NINJAMAS_ENTRIES}
        DEPENDS ninjamas
        COMMENT "Profiling a scripted session for runtime-only entry points")
    target_compile_definitions(ninjamas PRIVATE NINJAMAS_HAVE_RECOMP)
    if(MSVC)
        # This title's data-driven code yields two ~58k-line dispatch
        # functions.  MSVC's optimizer is superlinear on those and can spend
        # tens of minutes (or exhaust memory) at /O1.  /Od compiles them in
        # about a minute; the 68000 helpers keep normal optimization and the
        # measured game speed is still several times real-time.  The trade-off
        # is a larger executable (about 174 MB versus 59 MB at /O1).
        set_source_files_properties(${GEN_SOURCES} PROPERTIES COMPILE_OPTIONS "/bigobj;/Od")
    elseif(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
        # GCC at -O1 on those functions exceeds a Steam Deck-class memory
        # budget.  -O0 keeps the generated dispatch code cheap to compile;
        # the 68000 helpers keep normal Release optimization.
        set_source_files_properties(${GEN_SOURCES} PROPERTIES COMPILE_OPTIONS "-O0")
    endif()
endif()
if(MSVC)
    target_compile_definitions(ninjamas PRIVATE _CRT_SECURE_NO_WARNINGS)
    target_compile_definitions(ninjamas_recomp PRIVATE _CRT_SECURE_NO_WARNINGS)
endif()

# Ship the SDL2 DLL (when the window is built) next to the executable.
if(WIN32 AND TARGET SDL2::SDL2)
    add_custom_command(TARGET ninjamas POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_RUNTIME_DLLS:ninjamas> $<TARGET_FILE_DIR:ninjamas>
        COMMAND_EXPAND_LISTS)
endif()

