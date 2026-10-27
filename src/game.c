/*
 * game.c - Ninja Master's: Haoh-Ninpo-Cho (MAME set "ninjamas"), the
 * verified ROM layout shared by the player and the recompiler.
 *
 * The set is SNK's standard (unencrypted) MVS release on a plain PCM2 board:
 *
 *   217-p1.p1    1 MB fixed program bank, byte-swapped at rest
 *   217-p2.sp2   2 MB banked program data (standard 1 MB window register)
 *   217-c1..c8   32 MB sprite graphics in bitplane pairs
 *   217-s1.s1    128 KB fixed-layer graphics
 *   217-m1.m1    128 KB Z80 sound program
 *   217-v1/v2     6 MB ADPCM samples
 *
 * Every hash was checked against MAME 0.242's "ninjamas" set.  The cartridge
 * has no protection device and no non-standard mapper, so the generic bus
 * implements its $2FFFF0 bank register (1 MB granularity, low three bits)
 * without a game-specific bank table.
 *
 * P ROM ordering was verified from the data: after the 16-bit word swap the
 * first long is $0010F300 (initial SSP) and $00001000 (initial PC), and the
 * cartridge header at $100 reads "NEO-GEO".
 */
#include "game.h"

const ng_game_t k_ninjamas = {
    .name = "ninjamas",
    .title = "Ninja Master's - Haoh-Ninpo-Cho",
    .prom_size = 0x300000,          /* 1 MB fixed + 2 MB banked */
    .prom = {
        {"217-p1.p1",  0x000000, 0x000000, 0x100000, 1},
        {"217-p2.sp2", 0x000000, 0x100000, 0x200000, 1},
    },
    .crom_size = 0x2000000,         /* 32 MB after pairing */
    .crom_pairs = {
        {"217-c1.c1", "217-c2.c2"},
        {"217-c3.c3", "217-c4.c4"},
        {"217-c5.c5", "217-c6.c6"},
        {"217-c7.c7", "217-c8.c8"},
    },
    .srom = "217-s1.s1",
    .m1 = "217-m1.m1",
    .vrom = {"217-v1.v1", "217-v2.v2"},
};
