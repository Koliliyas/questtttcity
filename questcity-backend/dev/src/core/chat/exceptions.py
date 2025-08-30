class ChatNotFoundException(Exception):
    pass


class ChatWithSelfException(Exception):
    pass


class ChatBetweenUsersAlreadyExist(Exception):
    pass


class MessageNotFoundException(Exception):
    pass


class ParticipantNotFoundException(Exception):
    pass
