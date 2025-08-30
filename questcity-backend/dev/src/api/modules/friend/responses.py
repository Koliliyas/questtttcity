from api.modules.friend import exceptions as f_exc
from api.responses import base_responses, base_responses_with_auth
from api.utils import get_responses

get_friends_for_user_responses = get_responses([] + base_responses)

delete_friend_me_responses = get_responses(
    [f_exc.FriendshipNotFoundHTTPError()] + base_responses_with_auth
)
