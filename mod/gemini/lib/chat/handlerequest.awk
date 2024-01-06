


BEGIN{

    QUESTION          = ENVIRON[ "question" ]
    CHATID            = ENVIRON[ "chatid" ]
    MINION_JSON_CACHE = ENVIRON[ "minion_json_cache" ]
    SESSIONDIR        = ENVIRON[ "___X_CMD_CHAT_SESSION_DIR" ]

    MINION_KP = SUBSEP "\"1\""

    minion_load_from_jsonfile( minion_obj, MINION_KP, MINION_JSON_CACHE , "gemini")
    TYPE                = minion_type( minion_obj, MINION_KP )
    MODEL               = minion_model( minion_obj, MINION_KP )
    HISTORY_NUM         = minion_history_num( minion_obj, MINION_KP )
    SESSIONDIR          = SESSIONDIR "/" minion_session( minion_obj, MINION_KP )

    mkdirp( SESSIONDIR "/" CHATID )

    chat_history_load( history_obj, SESSIONDIR, HISTORY_NUM, CHATID)


    gemini_request_body_json            = gemini_req_from_creq( history_obj, minion_obj,  QUESTION )    # Notice: it's must before creq_create

    creq_create( creq_obj, minion_obj, MINION_KP,     TYPE, MODEL, USER_LATEST_QUESTION, CHATID, HISTORY_NUM )
    print creq_dump( creq_obj )         > (SESSIONDIR "/" CHATID "/chat.request.yml")

    print gemini_request_body_json      > (SESSIONDIR "/" CHATID "/gemini.request.body.yml")

    print SESSIONDIR "/" CHATID
    print MODEL
    print gemini_request_body_json
}


# {
#   "contents": [
#     {
#       text:
#       role:
#     }
#   ],

# {"contents":[{"parts":[{"text":"Write a story about a magic backpack"}]}]}
