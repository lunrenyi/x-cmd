
BEGIN{
    if (IS_TH_NO_COLOR != 1) {
        TH_THEME_COLOR = ENVIRON[ "___X_CMD_THEME_COLOR_CODE" ]
        TH_THEME_COLOR = (TH_THEME_COLOR) ? "\033[" TH_THEME_COLOR "m" : UI_FG_CYAN
    }
}

function ui_rotate1( screensize, fp,     line,     d, i ){
    i = IFS
    IFS = "\n"

    printf("%s", UI_LINEWRAP_DISABLE)  # This must be  the default ...
    printf("\033[?7l")

    while (getline line <fp ) {
        printf("\r%s")
    }

    IFS = i
}

function ui_rotate_fromstdin( n, prefix, exitclear, prompt_run, prompt_end,    i, o, _line, l, arr, _c ){
    prompt_run = ( prompt_run != "") ? prompt_run : "Running ..."
    prompt_end = ( prompt_end != "") ? prompt_end : "Done"
    for (i=1; i<=n; ++i)    printf("%s", "\r\n")
    printf("%s", "\033["int(n+1)"A" UI_CURSOR_SAVE UI_LINEWRAP_DISABLE) > "/dev/stderr"

    ring_init( o, n )
    while (getline _line) {
        l = split(_line, arr, "\n|\r")
        for (i=1; i<=l; ++i){
            _line = arr[i]
            if (_line ~ /^EXITCODE:/) {
                _c = int( substr( _line, 10 ) )
            }
            else {
                gsub("\033\\[[^A-Za-z]*[A-Za-z=]", "",  _line )
                gsub( "\n", "\\n", _line )
                gsub( "\t", "\\t", _line )
                gsub( "\v", "\\v", _line )
                gsub( "\b", "\\b", _line )
                gsub( "\r", "\\r", _line )
                ring_add( o, _line )
                ui_rotate_render( o, prefix )
                ui_rotate_render_prompt( o, prefix, prompt_run )
            }
        }
    }

    ui_rotate_render_prompt( o, prefix, prompt_end )
    printf ("%s", UI_LINEWRAP_ENABLE) > "/dev/stderr"
    if (exitclear == 1) ui_rotate_render_clear()
    return _c
}

function ui_rotate_render( o, prefix,      i, n, str ){
    ui_rotate_render_clear()

    n = ring_size( o )
    counter = ring_counter( o )
    for (i=1; i<=n; ++i) {
        str = sprintf("%4d  %s", (counter - n + i), ring_get( o, i ))
        printf("%s%s%s\n", prefix, th(TH_THEME_COLOR, "│ "), th(UI_FG_DARKGRAY, str)) > "/dev/stderr"
    }
}

function ui_rotate_render_clear(){
    printf( "%s", UI_CURSOR_RESTORE \
        UI_SCREEN_CLEAR_BOTTOM UI_LINE_CLEAR \
        "\r" UI_CURSOR_RESTORE UI_CURSOR_SAVE ) > "/dev/stderr"
}

function ui_rotate_render_prompt( o, prefix, prompt,    n ){
    n = ring_size( o )
    printf("%s", UI_CURSOR_RESTORE "\033[" n "B" \
        UI_SCREEN_CLEAR_BOTTOM UI_LINE_CLEAR) > "/dev/stderr"

    printf("%s%s%s\n", PREFIX, th(TH_THEME_COLOR, "└ "), prompt) > "/dev/stderr"
}