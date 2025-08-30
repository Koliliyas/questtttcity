from api.modules.favorite import exceptions as favorite_excs
from api.modules.quest.exceptions import QuestNotFoundHTTPError
from api.responses import base_responses_with_auth
from api.utils import get_responses

make_favorite_responses = get_responses(
    [QuestNotFoundHTTPError(), favorite_excs.FavoriteAlreadyExistsHTTPError()]
    + base_responses_with_auth
)

get_favorites_for_user_responses = get_responses([] + base_responses_with_auth)

delete_from_favorites_responses = get_responses(
    [favorite_excs.FavoriteNotFoundHTTPError()] + base_responses_with_auth
)
