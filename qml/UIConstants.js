/****************************************************************************
**
** Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the Qt Components project.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Nokia Corporation and its Subsidiary(-ies) nor
**     the names of its contributors may be used to endorse or promote
**     products derived from this software without specific prior written
**     permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
** $QT_END_LICENSE$
**
****************************************************************************/

.pragma library

// All sizes in gu

var FONT_FAMILY = "Nokia Pure Text";
var FONT_DEFAULT_SIZE = 1.5; // DEPRECATED

var FONT_XLARGE  = 2;
var FONT_LARGE   = 1.7;
var FONT_SLARGE  = 1.6;
var FONT_DEFAULT = 1.5;
var FONT_LSMALL  = 1.4;
var FONT_SMALL   = 1.3;
var FONT_XSMALL  = 1.2;
var FONT_XXSMALL = 1;

var SPOTIFY_COLOR = "#7AB800";
var SPOTIFY_ORANGE = "#EC5810";

var COLOR_FOREGROUND = "#191919"; // Text color
var COLOR_SECONDARY_FOREGROUND = "#8c8c8c"; // Secondary text
var COLOR_BACKGROUND = "transparent"; // Background
var COLOR_SELECT = "#4591ff"; //Selected item background

var COLOR_INVERTED_FOREGROUND = "#ffffff"; // Text color
var COLOR_INVERTED_SECONDARY_FOREGROUND = "#8c8c8c"; // Secondary text
var COLOR_INVERTED_BACKGROUND = "#000000"; // Background

var COLOR_DISABLED_FOREGROUND = "#b2b2b4";

var COLOR_BUTTON_FOREGROUND            = "#000000" //text color
var COLOR_BUTTON_INVERTED_FOREGROUND   = "#ffffff" //inverted text color
var COLOR_BUTTON_SECONDARY_FOREGROUND  = "#8c8c8c" //secondary text
var COLOR_BUTTON_DISABLED_FOREGROUND   = "#B2B2B4" //disabled text
var COLOR_BUTTON_BACKGROUND            = "#000000" //background

var SIZE_ICON_DEFAULT = 1.77;
var SIZE_ICON_LARGE = 2.88;

var CORNER_MARGINS = 1.22;

var MARGIN_DEFAULT = 0;
var MARGIN_XLARGE = 1;

// Distance in pixels from the widget bounding box inside which a release
// event would still be accepted and trigger the widget
var RELEASE_MISS_DELTA = 1.66;

var OPACITY_ENABLED = 1.0;
var OPACITY_DISABLED = 0.5;
var SIZE_BUTTON = 3.55;

var PADDING_XSMALL  = 0.2;
var PADDING_SMALL   = 0.4;
var PADDING_MEDIUM  = 0.6;
var PADDING_LARGE   = 0.8;
var PADDING_DOUBLE  = 1;
var PADDING_XLARGE  = 1.2;
var PADDING_XXLARGE = 1.5;

var SCROLLDECORATOR_SHORT_MARGIN = 0.44;
var SCROLLDECORATOR_LONG_MARGIN = 0.22;

var TOUCH_EXPANSION_MARGIN = -0.22;

var BUTTON_WIDTH = 17.88;
var BUTTON_HEIGHT = 2.83;
var BUTTON_LABEL_MARGIN = 0.55;

var FIELD_DEFAULT_HEIGHT = 2.88;

//Common UI layouts
var DEFAULT_MARGIN = 1;
var BUTTON_SPACING = 0.33;
var HEADER_DEFAULT_HEIGHT_PORTRAIT = 4;
var HEADER_DEFAULT_HEIGHT_LANDSCAPE = 2.55;
var HEADER_DEFAULT_TOP_SPACING_PORTRAIT = 1.11;
var HEADER_DEFAULT_BOTTOM_SPACING_PORTRAIT = 1.11;
var HEADER_DEFAULT_TOP_SPACING_LANDSCAPE = 0.88;
var HEADER_DEFAULT_BOTTOM_SPACING_LANDSCAPE = 0.77;
var LIST_ITEM_HEIGHT_SMALL = 3.55;
var LIST_ITEM_HEIGHT_DEFAULT = 4.44;

/* Margins */
var INDENT_DEFAULT = 1;
var CORNER_MARGINS = 1.22;
var MARGIN_DEFAULT = 0;
var MARGIN_XLARGE = 1;

// ListDelegate
var LIST_ITEM_MARGIN = 1;
var LIST_ITEM_SPACING = 0.88;
var LIST_ITEM_HEIGHT = 4.44;
var LIST_ICON_SIZE = 3.55;
var LIST_TILE_SIZE = 1.44;
var LIST_TITLE_COLOR = "#191919";
var LIST_TITLE_COLOR_INVERTED = "#ffffff";
var LIST_SUBTILE_SIZE = 1.22;
var LIST_SUBTITLE_COLOR = "#505050";
var LIST_SUBTITLE_COLOR_INVERTED = "#b8b8b8";

/* Font properties */
var FONT_FAMILY = "Nokia Pure Text";
var FONT_FAMILY_BOLD = "Nokia Pure Text";
var FONT_FAMILY_LIGHT = "Nokia Pure Text Light";
var FONT_DEFAULT_SIZE = 1.33;
var FONT_LIGHT_SIZE = 1.22;

/* TUMBLER properties */
var TUMBLER_COLOR_TEXT = "#FFFFFF";
var TUMBLER_COLOR_LABEL = "#8C8C8C";
var TUMBLER_COLOR = "#000000";
var TUMBLER_OPACITY_FULL = 1.0;
var TUMBLER_OPACITY = 0.4;
var TUMBLER_OPACITY_LOW = 0.1;
var TUMBLER_FLICK_VELOCITY = 38.88;
var TUMBLER_ROW_HEIGHT = 3.55;
var TUMBLER_LABEL_HEIGHT = 3;
var TUMBLER_MARGIN = 1;
var TUMBLER_BORDER_MARGIN = 0.05;
var TUMBLER_WIDTH = 19.11;
var TUMBLER_HEIGHT_PORTRAIT = 14.22;
var TUMBLER_HEIGHT_LANDSCAPE = 10.66;

/* Button styles */
// Normal
var COLOR_BUTTON_FOREGROUND = "#191919"; // Text color
var COLOR_BUTTON_SECONDARY_FOREGROUND = "#8c8c8c"; // Pressed
var COLOR_BUTTON_DISABLED_FOREGROUND = "#b2b2b4"; // Disabled
// Inverted
var COLOR_BUTTON_INVERTED_FOREGROUND = "#FFFFFF";
var COLOR_BUTTON_INVERTED_SECONDARY_FOREGROUND = "#8c8c8c"; // Pressed
var COLOR_BUTTON_INVERTED_DISABLED_FOREGROUND = "#f5f5f5"; // Disabled

var SIZE_BUTTON = 2.83;
var SIZE_SMALL_BUTTON = 2.38;
var WIDTH_SMALL_BUTTON = 6.77;
var WIDTH_TUMBLER_BUTTON = 12.33;

var FONT_BOLD_BUTTON = true;

var INFO_BANNER_OPACITY = 0.9;
var INFO_BANNER_LETTER_SPACING = -0.06;

