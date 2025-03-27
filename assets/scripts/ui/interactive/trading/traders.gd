extends Node

class_name Traders
var content:Dictionary = {
    'markUp': 1, #  15%
    1: {
        "inventory" = {
            "seasons": {
                "spring": {
                    13:{"amount": 1},
                    14:{"amount": 1},
                    15:{"amount": 1},
                    16:{"amount": 1},
                    17:{"amount": 1},
                },
                "summer": {
                    18:{"amount": 1},
                    19:{"amount": 1},
                    20:{"amount": 1},
                    21:{"amount": 1},
                    22:{"amount": 1},
                },
                "autumn": {
                    23:{"amount": 1},
                    24:{"amount": 1},
                    25:{"amount": 1},
                    26:{"amount": 1},
                    27:{"amount": 1},
                },
                "winter": {
                    28:{"amount": 1},
                    29:{"amount": 1},
                    30:{"amount": 1},
                    31:{"amount": 1},
                    32:{"amount": 1},
                },
            }
        }
    },
    2: {
        'onlyPurchase' = true,
        "inventory" = {
            5:{"amount": 1},
            6:{"amount": 1},
            7:{"amount": 1},
            8:{"amount": 1},
            9:{"amount": 1},
            10:{"amount": 1},
            11:{"amount": 1},
        }
    },
    3: {
        'onlyPurchase' = true,
        "inventory" = {
            1:{"amount": 1},
            2:{"amount": 1},
            3:{"amount": 1},
            4:{"amount": 1},
        }
    }
}