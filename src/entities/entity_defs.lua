ENTITY_DEFS = {
    --LEVEL 1 DEFS
    {    
        ['player'] = {
            type = 'player',
            height = 64,
            width = 32,
            walkSpeed = 60,
            startingHealth = 60,
            maxHealth = 100,
            groundOnly = false,
            animations = {
                ['idle-right'] = {
                    frames = {3},
                    texture = 'bad-man'
                },
                ['walk-right'] = {
                    frames = {1, 2},
                    interval = 0.5,
                    texture = 'bad-man'
                },
                ['steal-right'] = {
                    frames = {4},
                    interval = 0.2,
                    texture = 'bad-man'
                },
                ['idle-left'] = {
                    frames = {6},
                    texture = 'bad-man'
                },
                ['walk-left'] = {
                    frames = {8, 7},
                    interval = 0.5,
                    texture = 'bad-man'
                },
                ['steal-left'] = {
                    frames = {5},
                    interval = 0.2,
                    texture = 'bad-man'
                }
            }
        },
        ['baby'] = {
            type = 'baby',
            height = 32,
            width = 32,
            walkSpeed = 25,
            groundOnly = true,
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
            attackSeconds = 1,
            groundOnly = true,
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
            groundOnly = false,
            animations = {
                ['fly-left'] = {
                    frames = {1, 2},
                    interval = 0.2,
                    texture = 'bad-stork'
                }
            }
        },
        ['plane-mom'] = {
            type = 'plane-mom',
            height = 32,
            width = 64,
            walkSpeed = 80,
            attackSeconds = 1,
            groundOnly = false,
            animations = {
                ['fly-left'] = {
                    frames = {1, 2},
                    interval = 0.2,
                    texture = 'bad-plane-mom'
                }
            }
        }
    },
    -- LEVEL 2 DEFS
    {
        ['player'] = {
            type = 'player',
            height = 64,
            width = 32,
            walkSpeed = 40,
            startingHealth = 35,
            maxHealth = 60,
            groundOnly = false,
            animations = {
                ['idle-right'] = {
                    frames = {3},
                    texture = 'space-man'
                },
                ['walk-right'] = {
                    frames = {1, 2},
                    interval = 0.5,
                    texture = 'space-man'
                },
                ['steal-right'] = {
                    frames = {4},
                    interval = 0.2,
                    texture = 'space-man'
                },
                ['idle-left'] = {
                    frames = {5},
                    texture = 'space-man'
                },
                ['walk-left'] = {
                    frames = {6, 7},
                    interval = 0.5,
                    texture = 'space-man'
                },
                ['steal-left'] = {
                    frames = {8},
                    interval = 0.2,
                    texture = 'space-man'
                }
            }
        },
        ['baby'] = {
            type = 'baby',
            height = 32,
            width = 32,
            walkSpeed = 50,
            groundOnly = true,
            animations = {
                ['idle-left'] = {
                    frames = {1},
                    texture = 'space-baby'
                },
                ['crawl-left'] = {
                    frames = {1, 2},
                    interval = 0.2,
                    texture = 'space-baby'
                }
            }
        },
        ['mom'] = {
            type = 'mom',
            height = 64,
            width = 32,
            walkSpeed = 70,
            attackSeconds = .5,
            groundOnly = true,
            animations = {
                ['idle-left'] = {
                    frames = {1},
                    texture = 'space-mom'
                },
                ['walk-left'] = {
                    frames = {1, 2},
                    interval = 0.4,
                    texture = 'space-mom'
                }
            }
        },
        ['stork'] = {
            type = 'stork',
            height = 32,
            width = 64,
            walkSpeed = 120,
            groundOnly = false,
            animations = {
                ['fly-left'] = {
                    frames = {1, 2},
                    interval = 0.2,
                    texture = 'space-stork'
                }
            }
        },
        ['plane-mom'] = {
            type = 'plane-mom',
            height = 32,
            width = 64,
            walkSpeed = 150,
            attackSeconds = .5,
            groundOnly = false,
            animations = {
                ['fly-left'] = {
                    frames = {1, 2},
                    interval = 0.4,
                    texture = 'space-plane-mom'
                }
            }
        }
    }
}