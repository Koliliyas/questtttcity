from api.modules.profile.exceptions import ProfileNotFoundHTTPError
from api.responses import base_responses_with_auth
from api.utils import get_responses

update_me_profile_responses = get_responses(
    [ProfileNotFoundHTTPError] + base_responses_with_auth
)

update_profile_responses = get_responses(
    [ProfileNotFoundHTTPError] + base_responses_with_auth
)
