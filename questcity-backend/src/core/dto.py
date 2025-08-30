from dataclasses import asdict, dataclass


class BaseUpdateDTO:
    def get_non_none_fields(self):
        return {k: v for k, v in asdict(self).items() if v is not None}


@dataclass
class EmailMessageDTO:
    subject: str
    recipients: list[str]
    body: str
