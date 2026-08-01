params [
    ["_text",""],
    ["_size",1.5,[0]],
    ["_target",ACE_player,[objNull]],
    ["_width",10,[0]]
];

if (_target isNotEqualTo ACE_player) exitWith {
    false
};

if (typeName _text isNotEqualTo "TEXT") then {
    if (_text isEqualType []) then {
        if ((count _text) > 0) then {
            {
                if (
                    _x isEqualType "" &&
                    {isLocalized _x}
                ) then {
                    _text set [
                        _forEachIndex,
                        localize _x
                    ];
                };
            } forEach _text;

            _text = format _text;
        };
    };

    if (
        _text isEqualType "" &&
        {isLocalized _text}
    ) then {
        _text = localize _text;
    };

    _text = composeText [
        lineBreak,
        parseText format [
            "<t align='center'>%1</t>",
            _text
        ]
    ];
};

disableSerialization;

private _isShown = ctrlShown (
    uiNamespace getVariable [
        "ACE_ctrlHint",
        controlNull
    ]
);

(
    "ACE_RscHint" call BIS_fnc_rscLayer
) cutRsc [
    "ACE_RscHint",
    "PLAIN",
    0,
    true
];

private _ctrlHint = uiNamespace getVariable [
    "ACE_ctrlHint",
    controlNull
];

if (isNull _ctrlHint) exitWith {
    false
};

_ctrlHint ctrlSetBackgroundColor (
    missionNamespace getVariable [
        "ace_common_displayTextColor",
        [
            0,
            0,
            0,
            0.8
        ]
    ]
);

_ctrlHint ctrlSetTextColor (
    missionNamespace getVariable [
        "ace_common_displayTextFontColor",
        [
            1,
            1,
            1,
            1
        ]
    ]
);

private _gridW = (
    (
        safeZoneW /
        safeZoneH
    ) min 1.2
) / 40;

private _gridH = (
    (
        (
            safeZoneW /
            safeZoneH
        ) min 1.2
    ) /
    1.2
) / 25;

private _wPos = _width * _gridW;
private _hPos = _size * (
    2 * _gridH
);

private _xPos = profileNamespace getVariable [
    "IGUI_GRID_UKSF_PRC163_Notifications_X",
    (
        safeZoneX +
        safeZoneW
    ) -
    _wPos -
    (
        2.9 * _gridW
    )
];

private _yPos = profileNamespace getVariable [
    "IGUI_GRID_UKSF_PRC163_Notifications_Y",
    safeZoneY +
    (
        0.175 * safeZoneH
    )
];

_xPos = safeZoneX max (
    _xPos min (
        safeZoneX +
        safeZoneW -
        _wPos
    )
);

_yPos = safeZoneY max (
    _yPos min (
        safeZoneY +
        safeZoneH -
        _hPos
    )
);

if (!isNull curatorCamera) then {
    _xPos = _xPos min (
        (
            safeZoneX +
            safeZoneW -
            (
                12.5 * _gridW
            )
        ) -
        _wPos
    );
};

private _position = [
    _xPos,
    _yPos,
    _wPos,
    _hPos
];

_ctrlHint ctrlSetPosition _position;
_ctrlHint ctrlCommit 0;
_ctrlHint ctrlSetStructuredText _text;
_ctrlHint ctrlSetPosition _position;
_ctrlHint ctrlCommit (
    [
        0.5,
        0
    ] select _isShown
);

true
