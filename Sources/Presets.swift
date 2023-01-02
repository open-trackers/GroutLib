//
//  Presets.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Collections
import Foundation

public let routinePresets: OrderedDictionary = [
    "Strength Training": [
        "Back & Bicep",
        "Chest & Shoulder",
        "Circuit",
        "Leg",
        "Lower",
        "Pull",
        "Push",
        "Upper",
    ],
]

public let exercisePresets: OrderedDictionary = [
    "Machine/Free Weights": [
        "Abdominal",
        "Arm Curl",
        "Arm Ext",
        "Back Ext",
        "Bicep Curl",
        "Calf Ext",
        "Calf Raise",
        "Chest Press",
        "Dip/Chin",
        "Glute",
        "Hip Abduct",
        "Hip Adduct",
        "Incl Press",
        "Incl Pull",
        "Lat Pulldown",
        "Lat Raise",
        "Leg Ext",
        "Leg Press",
        "OH Press",
        "Pect Fly",
        "Prone Leg Curl",
        "Rear Delt",
        "Rotary Torso",
        "Row",
        "Seat Leg Curl",
        "Shoulder Press",
        "Squat",
        "Tri Press",
    ],
    "Bodyweight": [
        "Crunch",
        "Jumping-jack",
        "Jump",
        "Plank",
        "Pull-up",
        "Squat",
        "Walking lunge",
        "Push-up",
    ],
]

// initial pool of images to assign to routines
public let systemImageNames = [
    "dumbbell",
    "dumbbell.fill",
    "figure.strengthtraining.functional",
    "figure.strengthtraining.traditional",
    "figure.arms.open",
    "figure.barre",
    "figure.cooldown",
    "figure.fall",
    // "figure.core.training", getting a not found error from simulator
    "figure.cross.training",
    "figure.dance",
    "figure.flexibility",
    "figure.gymnastics",
    "figure.mind.and.body",
    "figure.mixed.cardio",
    "figure.pilates",
    "figure.rolling",
    "figure.run",
    "figure.wave",
    "figure.yoga",
    "airplane",
    "atom",
    "bicycle",
    "bolt.fill",
    "bolt.shield.fill",
    "burn",
    "carrot.fill",
    "crown.fill",
    "flag.2.crossed.fill",
    "flag.checkered",
    "flame",
    "fuelpump.fill",
    "hare.fill",
    "infinity",
    "key.fill",
    "pawprint.fill",
    "sparkles",
    "snowflake",
    "tornado",
    "tortoise.fill",
    "wind",
    // add new ones here
]
