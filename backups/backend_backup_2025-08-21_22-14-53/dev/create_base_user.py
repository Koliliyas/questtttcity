import asyncio
import dotenv
from db.models.user import User, Profile
from core.authentication.utils import hash_password
from db.engine import async_session_factory
dotenv.load_dotenv()

async def main():
    async with async_session_factory.begin() as session:
        profile = Profile(avatar_url=None)
        session.add(profile)
        await session.flush()
        password = str(hash_password("stringD#3"))
        admin = User(username="user", password=password, email="questcity-test@yandex.ru", is_verified=True, role=2, first_name="admin", last_name="admin", profile_id=profile.id)
        session.add(admin)

if __name__ == "__main__":
    asyncio.run(main())