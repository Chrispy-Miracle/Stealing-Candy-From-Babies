ENTITY_DEFS = {
    ['player'] = {
        type = 'player',
        height = 64,
        width = 32,
        walkSpeed = PLAYER_WALK_SPEED,
        startingHealth = 60,
        maxHealth = 100,
        animations = {
            ['idle-right'] = {
                frames = {3},
                texture = 'bad-man'
            },
            ['walk-right'] = {
                frames = {1, 2},
                interval = 0.4,
                texture = 'bad-man'
            },
            ['idle-left'] = {
                frames = {4},
                texture = 'bad-man'
            },
            ['walk-left'] = {
                frames = {6, 5},
                interval = 0.4,
                texture = 'bad-man'
            },
        }
    },
    ['baby'] = {
        type = 'baby',
        height = 32,
        width = 32,
        walkSpeed = 25,
        animations = {
            ['idle-left'] = {
                frames = {1},
                texture = 'bad-baby'
            },
            ['crawl-left'] = {
                frames = {1, 2},
                interval = 0.4,
                texture = 'bad-baby'
            }
        }
    },
    ['mom'] = {
        type = 'mom',
        height = 64,
        width = 32,
        walkSpeed = 40,
        animations = {
            ['idle-left'] = {
                frames = {1},
                texture = 'bad-mom'
            },
            ['walk-left'] = {
                frames = {1, 2},
                interval = 0.4,
                texture = 'bad-mom'
            }
        }
    },
    ['stork'] = {
        type = 'stork',
        height = 32,
        width = 64,
        walkSpeed = 60,
        animations = {
            ['fly-left'] = {
                frames = {1, 2},
                interval = 0.2,
                texture = 'bad-stork'
            }
        }
    }
}