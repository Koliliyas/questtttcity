-- QuestCity Database Backup (Proper Format)
-- Created: 2025-08-27 01:07:10.173810
-- Database: questcity_db


-- Table: activity
DROP TABLE IF EXISTS activity CASCADE;
CREATE TABLE activity (
    id integer NOT NULL DEFAULT nextval('activity_id_seq'::regclass),
    name character varying NOT NULL
);

-- Data for table activity
INSERT INTO activity VALUES (1, 'Catch a ghost');
INSERT INTO activity VALUES (2, 'Take a photo');
INSERT INTO activity VALUES (3, 'Download the file');
INSERT INTO activity VALUES (4, 'Scan Qr-code');
INSERT INTO activity VALUES (5, 'Enter the code');
INSERT INTO activity VALUES (6, 'Enter the word');
INSERT INTO activity VALUES (7, 'Pick up an artifact');


-- Table: alembic_version
DROP TABLE IF EXISTS alembic_version CASCADE;
CREATE TABLE alembic_version (
    version_num character varying NOT NULL
);

-- Data for table alembic_version
INSERT INTO alembic_version VALUES ('11cae1179d5e');


-- Table: category
DROP TABLE IF EXISTS category CASCADE;
CREATE TABLE category (
    id integer NOT NULL DEFAULT nextval('category_id_seq'::regclass),
    name character varying NOT NULL,
    image character varying NOT NULL,
    created_at timestamp without time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at timestamp without time zone NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Data for table category
INSERT INTO category VALUES (1, 'Adventure', 'https://images.unsplash.com/photo-1551632811-561732d1e306?w=400&h=400&fit=crop', '2025-08-11T09:11:39.780880', '2025-08-11T09:11:39.781057');
INSERT INTO category VALUES (2, 'Mystery', 'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400&h=400&fit=crop', '2025-08-11T09:11:39.782118', '2025-08-11T09:11:39.782120');
INSERT INTO category VALUES (3, 'History', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop', '2025-08-11T09:11:39.782619', '2025-08-11T09:11:39.782621');
INSERT INTO category VALUES (4, 'Nature', 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&h=400&fit=crop', '2025-08-11T09:11:39.783149', '2025-08-11T09:11:39.783150');
INSERT INTO category VALUES (5, 'Urban', 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=400&h=400&fit=crop', '2025-08-11T09:11:39.783578', '2025-08-11T09:11:39.783580');
INSERT INTO category VALUES (6, 'Technology', 'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400&h=400&fit=crop', '2025-08-11T09:11:39.783974', '2025-08-11T09:11:39.783975');


-- Table: chat
DROP TABLE IF EXISTS chat CASCADE;
CREATE TABLE chat (
    id integer NOT NULL DEFAULT nextval('chat_id_seq'::regclass),
    created_at timestamp without time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at timestamp without time zone NOT NULL DEFAULT timezone('utc'::text, now())
);


-- Table: chat_participant
DROP TABLE IF EXISTS chat_participant CASCADE;
CREATE TABLE chat_participant (
    chat_id integer NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL DEFAULT timezone('utc'::text, now())
);


-- Table: email_verification_code
DROP TABLE IF EXISTS email_verification_code CASCADE;
CREATE TABLE email_verification_code (
    code integer NOT NULL,
    email character varying NOT NULL,
    optional_data json,
    created_at timestamp without time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    expire_at timestamp without time zone NOT NULL
);


-- Table: favorite
DROP TABLE IF EXISTS favorite CASCADE;
CREATE TABLE favorite (
    id integer NOT NULL DEFAULT nextval('favorite_id_seq'::regclass),
    user_id uuid NOT NULL,
    quest_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at timestamp without time zone NOT NULL DEFAULT timezone('utc'::text, now())
);


-- Table: friend
DROP TABLE IF EXISTS friend CASCADE;
CREATE TABLE friend (
    id integer NOT NULL DEFAULT nextval('friend_id_seq'::regclass),
    user_id uuid NOT NULL,
    friend_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL DEFAULT timezone('utc'::text, now())
);


-- Table: friend_request
DROP TABLE IF EXISTS friend_request CASCADE;
CREATE TABLE friend_request (
    id integer NOT NULL DEFAULT nextval('friend_request_id_seq'::regclass),
    requester_id uuid NOT NULL,
    recipient_id uuid NOT NULL,
    friend_request_status_enum USER-DEFINED NOT NULL,
    updated_at timestamp without time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    created_at timestamp without time zone NOT NULL DEFAULT timezone('utc'::text, now())
);


-- Table: merch
DROP TABLE IF EXISTS merch CASCADE;
CREATE TABLE merch (
    id integer NOT NULL DEFAULT nextval('merch_id_seq'::regclass),
    description character varying NOT NULL,
    price double precision NOT NULL,
    image character varying NOT NULL,
    quest_id integer NOT NULL
);


-- Table: message
DROP TABLE IF EXISTS message CASCADE;
CREATE TABLE message (
    id integer NOT NULL DEFAULT nextval('message_id_seq'::regclass),
    text character varying NOT NULL,
    file_url character varying,
    is_read boolean NOT NULL,
    author_id uuid NOT NULL,
    chat_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at timestamp without time zone NOT NULL DEFAULT timezone('utc'::text, now())
);


-- Table: place
DROP TABLE IF EXISTS place CASCADE;
CREATE TABLE place (
    id integer NOT NULL DEFAULT nextval('place_id_seq'::regclass),
    name character varying NOT NULL
);

-- Data for table place
INSERT INTO place VALUES (1, 'Downtown LA');
INSERT INTO place VALUES (2, 'Hollywood');
INSERT INTO place VALUES (3, 'Venice Beach');
INSERT INTO place VALUES (4, 'Griffith Obs');
INSERT INTO place VALUES (5, 'Santa Monica');


-- Table: place_settings
DROP TABLE IF EXISTS place_settings CASCADE;
CREATE TABLE place_settings (
    id integer NOT NULL DEFAULT nextval('place_settings_id_seq'::regclass),
    longitude double precision NOT NULL,
    latitude double precision NOT NULL,
    detections_radius double precision NOT NULL,
    height double precision NOT NULL,
    random_occurrence double precision,
    interaction_inaccuracy double precision NOT NULL,
    part integer,
    point_id integer NOT NULL
);


-- Table: point
DROP TABLE IF EXISTS point CASCADE;
CREATE TABLE point (
    id integer NOT NULL DEFAULT nextval('point_id_seq'::regclass),
    name_of_location character varying NOT NULL,
    order integer NOT NULL,
    description character varying NOT NULL,
    type_id integer NOT NULL,
    type_photo USER-DEFINED,
    type_code character varying,
    type_word character varying,
    tool_id integer,
    file character varying,
    is_divide boolean,
    quest_id integer NOT NULL
);


-- Table: profile
DROP TABLE IF EXISTS profile CASCADE;
CREATE TABLE profile (
    id integer NOT NULL DEFAULT nextval('profile_id_seq'::regclass),
    avatar_url character varying,
    instagram_username character varying NOT NULL,
    credits integer NOT NULL
);

-- Data for table profile
INSERT INTO profile VALUES (1, NULL, '', 0);
INSERT INTO profile VALUES (2, NULL, '', 0);
INSERT INTO profile VALUES (3, NULL, '', 0);
INSERT INTO profile VALUES (4, NULL, '', 0);


-- Table: quest
DROP TABLE IF EXISTS quest CASCADE;
CREATE TABLE quest (
    id integer NOT NULL DEFAULT nextval('quest_id_seq'::regclass),
    name character varying NOT NULL,
    description character varying NOT NULL,
    image character varying NOT NULL,
    mentor_preference character varying NOT NULL,
    auto_accrual boolean NOT NULL,
    cost integer NOT NULL,
    reward integer NOT NULL,
    category_id integer NOT NULL,
    group USER-DEFINED NOT NULL,
    vehicle_id integer NOT NULL,
    is_subscription boolean NOT NULL,
    pay_extra integer NOT NULL,
    timeframe USER-DEFINED,
    level USER-DEFINED NOT NULL,
    milage USER-DEFINED NOT NULL,
    place_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at timestamp without time zone NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Data for table quest
INSERT INTO quest VALUES (3, 'Beach Discovery', 'Explore the beautiful Venice Beach area', 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&h=400&fit=crop', 'GUIDE', false, 20, 30, 4, 'TWO', 2, false, 0, 'ONE_HOUR', 'EASY', 'UP_TO_TEN', 3, '2025-08-11T09:11:39.798350', '2025-08-11T09:11:39.798351');
INSERT INTO quest VALUES (4, 'Observatory Quest', 'Discover the wonders of Griffith Observatory', 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&h=400&fit=crop', 'GUIDE', false, 30, 40, 3, 'TWO', 4, false, 0, 'THREE_HOURS', 'MIDDLE', 'UP_TO_TEN', 4, '2025-08-11T09:11:39.798950', '2025-08-11T09:11:39.798951');
INSERT INTO quest VALUES (5, 'Pier Adventure', 'Experience the magic of Santa Monica Pier', 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=400&fit=crop', 'GUIDE', false, 22, 32, 5, 'TWO', 1, false, 0, 'ONE_HOUR', 'EASY', 'UP_TO_TEN', 5, '2025-08-11T09:11:39.799538', '2025-08-11T09:11:39.799540');
INSERT INTO quest VALUES (11, 'Test Quest', 'Test description', 'https://images.unsplash.com/photo-1551632811-561732d1e306?w=400&h=400&fit=crop', '', false, 0, 0, 1, 'TWO', 1, false, 0, 'ONE_HOUR', 'EASY', 'UP_TO_TEN', 1, '2025-08-11T09:33:20.454699', '2025-08-11T09:33:20.454699');
INSERT INTO quest VALUES (12, 'Updated Test Quest 2', 'Updated test description 2', 'https://images.unsplash.com/photo-1551632811-561732d1e306?w=400&h=400&fit=crop', '', false, 0, 0, 1, 'TWO', 1, false, 0, 'ONE_HOUR', 'EASY', 'UP_TO_TEN', 1, '2025-08-11T09:41:42.380060', '2025-08-11T09:41:51.178215');
INSERT INTO quest VALUES (13, 'Updated Frontend Test Quest', 'Updated test description from frontend', 'https://images.unsplash.com/photo-1551632811-561732d1e306?w=400&h=400&fit=crop', '', false, 0, 0, 1, 'TWO', 1, false, 0, 'ONE_HOUR', 'EASY', 'UP_TO_TEN', 1, '2025-08-11T09:43:24.822944', '2025-08-11T09:43:35.113802');
INSERT INTO quest VALUES (14, 'Updated Frontend Test Quest 2', 'Updated test description from frontend 2', 'https://images.unsplash.com/photo-1551632811-561732d1e306?w=400&h=400&fit=crop', '', false, 0, 0, 1, 'TWO', 1, false, 0, 'ONE_HOUR', 'EASY', 'UP_TO_TEN', 1, '2025-08-11T10:03:01.679841', '2025-08-11T10:03:14.156613');
INSERT INTO quest VALUES (15, 'Super test1', 'test1', 'https://images.unsplash.com/photo-1551632811-561732d1e306?w=400&h=400&fit=crop', '', false, 0, 0, 1, 'TWO', 1, false, 0, 'ONE_HOUR', 'EASY', 'UP_TO_TEN', 1, '2025-08-11T10:26:54.980945', '2025-08-11T10:26:54.980945');
INSERT INTO quest VALUES (16, 'Test quest', 'Description', 'https://images.unsplash.com/photo-1551632811-561732d1e306?w=400&h=400&fit=crop', '', false, 0, 0, 1, 'TWO', 1, false, 0, 'ONE_HOUR', 'EASY', 'UP_TO_TEN', 1, '2025-08-11T10:32:33.651740', '2025-08-11T10:32:33.651740');
INSERT INTO quest VALUES (17, 'Super test2', 'test', 'https://images.unsplash.com/photo-1551632811-561732d1e306?w=400&h=400&fit=crop', '', false, 0, 0, 1, 'TWO', 1, false, 0, 'ONE_HOUR', 'EASY', 'UP_TO_TEN', 1, '2025-08-11T10:41:34.529528', '2025-08-11T10:41:34.529528');
INSERT INTO quest VALUES (18, 'Test quest create', 'desciption', 'https://images.unsplash.com/photo-1551632811-561732d1e306?w=400&h=400&fit=crop', '', false, 0, 0, 1, 'TWO', 1, false, 0, 'ONE_HOUR', 'EASY', 'UP_TO_TEN', 1, '2025-08-11T10:50:19.094013', '2025-08-11T10:50:19.094013');


-- Table: refresh_token
DROP TABLE IF EXISTS refresh_token CASCADE;
CREATE TABLE refresh_token (
    id character varying NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Data for table refresh_token
INSERT INTO refresh_token VALUES ('_ATPmAvinRBx4jvPbbbeuFjGsitTT5HRA7VUsvk0VuM', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T10:07:49.221430');
INSERT INTO refresh_token VALUES ('4jdi_zNa1vR-6UvQ_oehlAEwT3Waio2Oy8YRJkXQK80', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T10:08:07.281604');
INSERT INTO refresh_token VALUES ('9wVVSyvuCQ0HRovGXTCbydhIBC-FItbdyCkvSn6vG20', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T10:09:20.470297');
INSERT INTO refresh_token VALUES ('Z0qtW0I_eltxlkEwBrjmSwJ9jfYrppgHMooCD4V3I2o', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T10:13:01.187880');
INSERT INTO refresh_token VALUES ('YCywyBBE6LmLhSKfkrQblJt73sMjl51h38jCknEptXg', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T10:13:22.817207');
INSERT INTO refresh_token VALUES ('tKQvyZ8UUMbIpgi7eqKXDN_lzdSptBP8V1tmsS-EZVY', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T10:13:33.492942');
INSERT INTO refresh_token VALUES ('xa0Qg4UzZSxfcCfga6iyDuYgNvnJj1iPMBQ__60m1qA', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T10:13:36.928644');
INSERT INTO refresh_token VALUES ('Z3jA3Xrge0Q4Th6DJgTqDY0gv-kAlPPojD6P6lp1Y60', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T10:25:25.618371');
INSERT INTO refresh_token VALUES ('U_GTcBzhQO_91hTkWuwJ314DDL96dCxT4ulnl6MYrs8', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T10:26:47.822337');
INSERT INTO refresh_token VALUES ('0vQlFzklxrL5wAfba4QA_qBmLabFMg6UK6vHj8i6xiE', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T10:29:07.262905');
INSERT INTO refresh_token VALUES ('8DCS10E9P78fqvKe0jxxbF017Na6IHO4JIvs2pcG8WY', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T10:29:46.302472');
INSERT INTO refresh_token VALUES ('VG183BWb_1IDKlyyMqx44yz13TtqIS2H5dqbxccIudA', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T10:49:24.320461');
INSERT INTO refresh_token VALUES ('Hc0CsDBkW0PX7mpfN5vtBcCF5j306gd-IIgC3Ch6Mn0', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T11:06:33.655386');
INSERT INTO refresh_token VALUES ('1zTOfjcjpLUsKBIJ5NmFQRurYFC9PwCZJM_MDU9Y-jM', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T11:09:35.192675');
INSERT INTO refresh_token VALUES ('Ve9VKh6QmwUm4HTG-FHJ0j9oeYrJeh4K1ohET2LteJI', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T11:10:06.915141');
INSERT INTO refresh_token VALUES ('00I8fg6Opd-Tnb03kJJcHThNRazW9GVQM7FYtpbrzfI', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T11:48:23.287471');
INSERT INTO refresh_token VALUES ('VEOQOf-Htw_FnCzdj4v9LSibnp9_1i5vC_Gn0LtzN28', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T11:48:47.584571');
INSERT INTO refresh_token VALUES ('G8CsrqqsIQwuf_yskwmabaKP23FKxRWNVGO8NY2QlRE', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T11:48:55.987470');
INSERT INTO refresh_token VALUES ('ilkgqml_gpqTupN9PUXh-v7cvMxMmQsN0QXJMLxcuQE', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T11:50:42.748966');
INSERT INTO refresh_token VALUES ('RrivaTBc2pFxE3e9F2yvLYFKpl4C9AFDjLGI3-ttXLY', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T11:52:43.888897');
INSERT INTO refresh_token VALUES ('RSU8TBTcTvMRLD1-yBFELkBETBTV39Z-AHoxwwgxKTQ', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T11:53:45.060810');
INSERT INTO refresh_token VALUES ('Oc5GkCOWsQn8AOduCTJONGDPGEGxQMaFcnZn6R0pxtU', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T11:58:39.678729');
INSERT INTO refresh_token VALUES ('opEeyDCLb_dGyH3z36XqEcDJ0RuCfU35zbGv_1Fa8XQ', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T12:14:24.808652');
INSERT INTO refresh_token VALUES ('FkK7TaU3qN0YNYRQWepkRozIn1emNwLH4ADCGd8xvbM', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T12:15:17.692560');
INSERT INTO refresh_token VALUES ('iKdrRtFQHvPJ6tDwJWB_CNQyjp7V3zla-fBbrB3rr38', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T12:18:26.600072');
INSERT INTO refresh_token VALUES ('F7xJ30v54a_QZ_pO030DHll3aApeNiWsok-zr8mYSfs', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T12:18:40.642979');
INSERT INTO refresh_token VALUES ('jZYC8K-z45IIp5uZimBLE5x2tgj1KqkymWP8wHJRU7E', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T12:25:55.445982');
INSERT INTO refresh_token VALUES ('8ZNluStalRyH1xOiDXE5pYKPx68lftC2dzasPGxsHsY', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T12:26:05.125487');
INSERT INTO refresh_token VALUES ('7XMUx95oeL6iNO1_PvkzgaQl1ZpgNS-lh4T9tIt0Vq8', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T12:26:20.273127');
INSERT INTO refresh_token VALUES ('jrMNvpyHO5_qyuy272SbXr9KbGCT3VRhfrRQkmUbclk', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T12:26:31.829679');
INSERT INTO refresh_token VALUES ('7PAcgoi_u-LVn9eyucYrPevvBp3AqkJmkIpcY9YQv00', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T12:27:07.415875');
INSERT INTO refresh_token VALUES ('PMkCG7_fMfQjLjcY28TDxLnjicEG-mhA5yo23GuuqIA', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T12:36:29.953495');
INSERT INTO refresh_token VALUES ('4fJoA5JVFQSDe-M3K2nhtC13-girv1eQUqMLRpr5B0g', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T12:36:34.037649');
INSERT INTO refresh_token VALUES ('X85F8KFU-Hdp7YaZ0FjuV71oQXaQexyFuI2qd3sABGs', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T12:36:38.874787');
INSERT INTO refresh_token VALUES ('4d_c5rmS1oWj323QwbARrPIsEjFfy67WTk1153rWzWg', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T12:51:38.079115');
INSERT INTO refresh_token VALUES ('Zls0SbEHH-Xr6pmJAqRO1eYovYmQYz-z6m5w04VYrBg', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T12:51:41.266600');
INSERT INTO refresh_token VALUES ('d7iMhFF103Gv1CMjemsYB75sOHcNGLEqXYHGnPVg5ZY', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T12:51:44.885905');
INSERT INTO refresh_token VALUES ('zi9_nP_bNlRCvbvOQmv9tOayxO3qW9B7G2VabTBFOQI', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T12:53:41.950485');
INSERT INTO refresh_token VALUES ('0Bzw5DS-QCVyKseIyj2LzqRF2T2g_HKVCtfuZXad0Fw', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T12:53:46.870846');
INSERT INTO refresh_token VALUES ('mDGK_E_NsaatQ9iaX0oG2OvMVzaB5mZVc9RE1c197BA', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T12:53:52.251317');
INSERT INTO refresh_token VALUES ('TajDwXmxr1NRGxNhYyBeD98b0-QVXKTr3qskrQIS2rI', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T12:53:55.295768');
INSERT INTO refresh_token VALUES ('w2PU79CaMg5k9UOPLRbPDrmmSgBriPznYT49QE1Cwck', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T12:53:58.636461');
INSERT INTO refresh_token VALUES ('q9vuHWkYWa2KE60Zow05RJMmfk6tG-iveHdl-PCWQTk', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T13:19:35.491560');
INSERT INTO refresh_token VALUES ('HC9yj27Xbb8-7vgdkYwRcHPWLMDSpa2DYvR6Ae4dROg', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T13:22:19.691416');
INSERT INTO refresh_token VALUES ('RULMqtmxcVSXV2XKKSAdhbxxn6GXbflkXNo48eyGQ8Y', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T13:31:00.385860');
INSERT INTO refresh_token VALUES ('ko3DLvcmbdXqPYXmS-oDZjQTTY_Eit0uojJrLSmEHyw', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T13:31:27.503079');
INSERT INTO refresh_token VALUES ('pPm-sKqn7lEyJebEPAih8g5gafWE8QCVv5x78axnFFE', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T13:35:52.556823');
INSERT INTO refresh_token VALUES ('vpHX4mLnrVS8o7ZWEBJTcVPiPEe2Eh5hYc3Zl_U9jpk', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T13:36:23.089429');
INSERT INTO refresh_token VALUES ('HAPW3bBREQ81cs5cYiNaoLMO6zL-VIcIVGrnqufRcks', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T13:39:25.047984');
INSERT INTO refresh_token VALUES ('bxFvqkE8zBKAXr-rLuQJ6WenDv8Hkd8NCjAmXClZeKM', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T13:39:50.964689');
INSERT INTO refresh_token VALUES ('5DrJoHgnkUGZkB7YJZKWIqnkKBqkoCobVZe4thVtOYs', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T14:05:54.717961');
INSERT INTO refresh_token VALUES ('78SIRPTzaAbHzzG3K-i8DRX7lkchLAIhT56EQbGi_sY', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T14:21:46.080471');
INSERT INTO refresh_token VALUES ('KLJnFeLpv-F670NGYDKOEN1cbngXacrFINFjPjmqYZA', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T14:23:50.594860');
INSERT INTO refresh_token VALUES ('PXsjv6F3YWNHPijK9wiV7GC8KqWfkTZjAtRCc0RXei0', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T14:36:24.903998');
INSERT INTO refresh_token VALUES ('uIFRm6QFpEvqemh0LqInlWyZYuMoct2KiAdDSw3ti54', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T14:39:19.440367');
INSERT INTO refresh_token VALUES ('8_E30G9s7fst3zQKJjuBjz_qzT8tNRiR2bSLMRHGJXU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T14:42:16.937899');
INSERT INTO refresh_token VALUES ('Rwlev8zD_aBjLlMOH1wbeEFd21X6EhcE_2Q4oh5YeGI', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T14:45:05.511327');
INSERT INTO refresh_token VALUES ('fNA2qSwtSnKqTfP_GpOk1z0UZR8VyMLRWfE5eTECBmA', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T14:55:09.158477');
INSERT INTO refresh_token VALUES ('udgGwlYCgQk6TK53g-C0x6Z2O3G8EHi1EQG3yndUDIs', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T14:57:34.591510');
INSERT INTO refresh_token VALUES ('LXbTHzuZ8ATMXOxdWUNfqJBx_Q6JytHdO6byI7WFbvo', 1b667c9b-3c0f-4197-baf5-fb9a9fd9d6e9, '2025-08-07T14:58:42.282658');
INSERT INTO refresh_token VALUES ('LuWhf2YQV_fc_KjcnSdJRqB_Gg24rViH7jmprcTNMwM', 1b667c9b-3c0f-4197-baf5-fb9a9fd9d6e9, '2025-08-07T15:00:17.232233');
INSERT INTO refresh_token VALUES ('-g5C4c0c4l8hn9EcB8rJT7sqCOCsECc8XuuIVLHnus4', 1b667c9b-3c0f-4197-baf5-fb9a9fd9d6e9, '2025-08-07T15:01:15.977344');
INSERT INTO refresh_token VALUES ('3-MLkTkQP3oz0FaiqG2mq-H5BZ9-6e3I_7fMVwq1jEs', 1b667c9b-3c0f-4197-baf5-fb9a9fd9d6e9, '2025-08-07T15:03:58.947590');
INSERT INTO refresh_token VALUES ('lWjk5Jtv1-u8XomMntlCiNi_PoNIBVsyWExp3K_zcxw', 1b667c9b-3c0f-4197-baf5-fb9a9fd9d6e9, '2025-08-07T15:07:08.929133');
INSERT INTO refresh_token VALUES ('jkNYcaU9p2sQHAaV9umtVskQA3GVQnG0cprlzwvFj68', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-07T15:09:09.816668');
INSERT INTO refresh_token VALUES ('F57nriNo66OVZzuAnsvFn-CdVv2TdbrOsoiBGiNDPVg', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T15:09:53.978606');
INSERT INTO refresh_token VALUES ('BZMi09EgTa_KXnxuvtelL2aXPOfqODGjMx0cTwsZeSs', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T15:21:41.724861');
INSERT INTO refresh_token VALUES ('h0patovsjlSB8cf0IAcqR_5QA8sPjF821aQN9hMChqo', 1b667c9b-3c0f-4197-baf5-fb9a9fd9d6e9, '2025-08-07T15:23:11.913332');
INSERT INTO refresh_token VALUES ('Bwini3B06mMIH5fU6PxCvbowAJHmbnxUUosICyJnMVY', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T15:30:09.656671');
INSERT INTO refresh_token VALUES ('RjoA6oYP7SfE8ElcKhYA1djfbEqgtvJs2KKT7PqPb7g', 1b667c9b-3c0f-4197-baf5-fb9a9fd9d6e9, '2025-08-07T15:31:32.728885');
INSERT INTO refresh_token VALUES ('tKBKydKFhPQ-9NDs_cD6x6rSb2wQNfC_KWaWADQiEzQ', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T15:37:37.739214');
INSERT INTO refresh_token VALUES ('hQYRZEOGXqNmoagvVdb60TmKIlv1rJjUHqOccr0L9hM', 1b667c9b-3c0f-4197-baf5-fb9a9fd9d6e9, '2025-08-07T15:38:36.623410');
INSERT INTO refresh_token VALUES ('N2byvPOTeTDPPjVJspwf2w-zay8UxuTrwTLZ5wvkaOo', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T15:42:08.716394');
INSERT INTO refresh_token VALUES ('NOHtUDhgMIyM8qCBkzOWalqM0sX65zIYqzLyAhRR850', 1b667c9b-3c0f-4197-baf5-fb9a9fd9d6e9, '2025-08-07T15:44:53.374388');
INSERT INTO refresh_token VALUES ('H0clkHUEBGaoNahrbTauQxOzPyihX3PcxQBZSBFtHw8', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T15:49:16.024154');
INSERT INTO refresh_token VALUES ('b07bgppuucHcfoHWVSYR3Z_VS1azz_OQYTw8emB5Yxs', 1b667c9b-3c0f-4197-baf5-fb9a9fd9d6e9, '2025-08-07T15:50:12.748650');
INSERT INTO refresh_token VALUES ('CulL3SGrh-0FQWRFCEVJYU4bohiCjzYFQ8QH4ETv0II', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T15:55:49.809030');
INSERT INTO refresh_token VALUES ('s3Ga7ZBkgWtXa57G5XvQR47MB-4uPASbONJMiOoZL-0', 1b667c9b-3c0f-4197-baf5-fb9a9fd9d6e9, '2025-08-07T15:56:16.871462');
INSERT INTO refresh_token VALUES ('bq_zW6SZ55QV8-5mlm7k5YOk7d4e_ZaodgqcXta3Vk0', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T16:00:04.445993');
INSERT INTO refresh_token VALUES ('M7klIQReVq18Q9M3kq2gRW1RgFU_IFvHX7FuRT3TIXA', 1b667c9b-3c0f-4197-baf5-fb9a9fd9d6e9, '2025-08-07T16:02:05.302121');
INSERT INTO refresh_token VALUES ('1TJQvUU97-9bgVyhGexExkSWPExsC6kaNg6oeoETl1w', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T16:09:02.353857');
INSERT INTO refresh_token VALUES ('mvQv59pwhBvCz_VTqKbOBgsEKsEZSk4_l2vPZjtaJoE', 1b667c9b-3c0f-4197-baf5-fb9a9fd9d6e9, '2025-08-07T16:09:14.234259');
INSERT INTO refresh_token VALUES ('cmBtTOOJ1P49O15oFfeLwRJNjK5zBcCClvsUrcmHEmU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-07T16:24:54.901746');
INSERT INTO refresh_token VALUES ('a6leKKeNrRnaz24ztFtwq6WUyimjOGT9mz6n1Fn_ZUY', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-08T10:33:24.292024');
INSERT INTO refresh_token VALUES ('ckQvltBIXYh-rlxPXMSJa4aus0EQgIhbWePVo8R6Jsk', 1b667c9b-3c0f-4197-baf5-fb9a9fd9d6e9, '2025-08-08T10:34:12.680710');
INSERT INTO refresh_token VALUES ('Ql0gLiMPN7c9upb4PCWMiwaCozOdwzVC7kLyw00Tc3c', 1b667c9b-3c0f-4197-baf5-fb9a9fd9d6e9, '2025-08-08T10:35:02.179000');
INSERT INTO refresh_token VALUES ('fga2TTyFEmW4D-vnxkqxQ77PopLqU1ny9N57fRp90Vk', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-08T10:59:55.938238');
INSERT INTO refresh_token VALUES ('EWN11CPiFBCLW9SZQSwUFpQoPwLL8nO_IL_TnbOv0wQ', 1b667c9b-3c0f-4197-baf5-fb9a9fd9d6e9, '2025-08-08T11:02:04.961799');
INSERT INTO refresh_token VALUES ('RQht87DUrflshzXsRy_GSKpDr6i54eaX1oUqfHF0eJQ', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-08T11:05:54.164108');
INSERT INTO refresh_token VALUES ('oJoSlJdkpSHd70Niz_gmoEmwyPa31FOckdbvyFRY0oo', 1b667c9b-3c0f-4197-baf5-fb9a9fd9d6e9, '2025-08-08T11:06:51.992850');
INSERT INTO refresh_token VALUES ('ZhL7tES1gt8zYXCoDK0cBDayUGROLLFU0rBJPZzDIBo', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-08T11:09:25.565728');
INSERT INTO refresh_token VALUES ('6hWQFDzrZcTvTrrUCzk4mKKd6uLT6w4iGcFOgpCnAVU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-08T11:10:09.433277');
INSERT INTO refresh_token VALUES ('TuT62GVWHESWYiDWvB1CtN7PfvhdQnCZDitSQZR3qy8', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-08T11:14:17.700214');
INSERT INTO refresh_token VALUES ('OlE5pLOV3RXbYug0h8Bn16mFNq9xtIrglHkiNsCw2ss', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-08T11:28:38.641578');
INSERT INTO refresh_token VALUES ('ozT3oUHjQlpss0JfxHU7tC6spPIahMezhB10y-49z1c', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-08T11:28:50.581850');
INSERT INTO refresh_token VALUES ('a9_3o8m6MP4DbRwptHRp-iAYFZB6sLd2w4b40XeP8cI', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-08T11:29:35.055574');
INSERT INTO refresh_token VALUES ('7lDLKKWIecfItjO5M0pnNBSHix4atxxeZ4l0pKx90AA', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-08T11:30:50.459432');
INSERT INTO refresh_token VALUES ('0MJVDiBAD3UoLyoOnIgkKxfGImPBJyCbTvezoSbZRSI', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-08T11:34:38.574505');
INSERT INTO refresh_token VALUES ('8du9FNHld23CQgkKKkqU_i9TxyzJ-VKILBYUwTWr7W8', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-08T11:36:54.394108');
INSERT INTO refresh_token VALUES ('roDqg1dNm1Y2Boj8qJqvykTPpgIFuEX9cieXpo2D3uY', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-08T11:40:17.313834');
INSERT INTO refresh_token VALUES ('rGbp-dEUOrpb13hKru5zFtZekdSu35gLV7VFjDpV6Sg', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-08T11:40:57.750971');
INSERT INTO refresh_token VALUES ('-auC69Cv2Q-Pz2RxlXjUfN9FBXt6ej7UEC9CYvewXeg', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-08T11:43:22.856101');
INSERT INTO refresh_token VALUES ('DaM97BP3zXXyUZc3UDcC_MVjlybo9H_cRDOViax1en4', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-08T11:44:40.409489');
INSERT INTO refresh_token VALUES ('nQzMPXGTxWktpGWJ8HvNArCzRi0mo6yaxy2UG3aYBW4', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-08T11:46:54.225901');
INSERT INTO refresh_token VALUES ('2TgqLxRQ8J8nSIJNUmKzcxYK6-XCFzRh7hLPiJRh2sE', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-08T11:48:44.228849');
INSERT INTO refresh_token VALUES ('bCKdDFQg4_zUhpTpp_I79I_59PRUJb3Y_rgPe84Xjpk', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T07:59:56.996966');
INSERT INTO refresh_token VALUES ('b7NssWxSese81OVBGb9arnQQpReRrYRafm-KBBPpUto', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T08:01:13.903083');
INSERT INTO refresh_token VALUES ('XhX_xRhv-TZMLLePfOz7FxlTyz-R5OmFmc1cc_8FgEo', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T08:17:10.509536');
INSERT INTO refresh_token VALUES ('nPOlDM3oMTuJc049cTWJqVny1aFhrH0Bpj_wsJf219c', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T08:18:58.299984');
INSERT INTO refresh_token VALUES ('oOluoWmhFYsZAZUJRzkAUL_tmFrQLsXwLO_x4TzJ2ig', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T08:20:05.138730');
INSERT INTO refresh_token VALUES ('nWt-36rFiWpYYoALdVnc5CHxehHUzEI-yzvr8Mje2YE', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T08:21:17.762294');
INSERT INTO refresh_token VALUES ('QsSwgpsFqpBDl49nKdjmu5AP5xpIbbNgXfgeGUqeYGI', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T08:22:35.498413');
INSERT INTO refresh_token VALUES ('QrrrW0OptWc8EKHtTvtPOJJATEdJBvya8PEB-8NKL7c', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T08:24:04.765076');
INSERT INTO refresh_token VALUES ('Xopx7PQ2rKB5Ez2ONE9Tijzk1Lb3OZKzhchzuEY5Osw', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T08:30:39.619323');
INSERT INTO refresh_token VALUES ('UT6R-sBljXrpBFXXQflxKVX6ACnhI1XKg2JTPHk4Fy0', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T08:36:34.986067');
INSERT INTO refresh_token VALUES ('snaNq7oK-bzsZa9f-qgkjw8LnGlW5OhdWowsQGGtatk', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T08:37:36.224604');
INSERT INTO refresh_token VALUES ('P1yl-ykZlVM-n-cGrcRgM6RM9DTMcUzfhCCG68RoaGg', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T08:43:22.542590');
INSERT INTO refresh_token VALUES ('HSRIhHHv_X33rYIBhS7IFJ8pqXMrmpH44aAGvemafxw', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T09:12:57.093849');
INSERT INTO refresh_token VALUES ('pIEPQbkolVJzBCky_5qJ2lhhMeRT0W9AhsYHIZdpM1E', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T09:13:25.019549');
INSERT INTO refresh_token VALUES ('HtfCEQeQHQbFMFyBksce6ajp8MxSnCMVQOx7jt-VxFs', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T09:27:46.836992');
INSERT INTO refresh_token VALUES ('Wh-6Cy9UoZrWXOeLgoRM2tpJGK0KO52t3Z2vtfTyHSQ', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T09:41:17.728440');
INSERT INTO refresh_token VALUES ('yM0vp7-7xVDXKAYb5XbM1PfdJWA_GUuO4_YKVaUAVuo', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T09:44:18.467773');
INSERT INTO refresh_token VALUES ('8uMgt9rWPlIiKMj4Hd4LHiPlz0STfyBaAzjHLaWH8qU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T09:45:19.948841');
INSERT INTO refresh_token VALUES ('xengFZMxL-jBCO3wTMYDJaDMb3BnIZt3v8b1ewlIxX0', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T10:02:42.139474');
INSERT INTO refresh_token VALUES ('gYjZCPVaGtlm7gKhxz-PZ1PAEq5V6FctcP-v9Zkq7h8', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T10:25:14.081852');
INSERT INTO refresh_token VALUES ('YjqatunzUlz0NivNExC8eUKmtgOMYss-36IkVXJwVyw', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T10:26:08.305333');
INSERT INTO refresh_token VALUES ('Q7n6xb6Dfb6mzHfN1GCCpUJXZ7w6oPi_-rebdnZgu5s', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T10:32:03.349798');
INSERT INTO refresh_token VALUES ('T5567Ol9VO1Shbg3oITz-H8uYZo_bhJrLO95JswlvK8', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T10:41:09.227982');
INSERT INTO refresh_token VALUES ('jOVrouJyZ5OF865u9UokW4NUUhgh0pHXnYip6s4z880', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T10:49:54.966885');
INSERT INTO refresh_token VALUES ('edfrikdqTd9HZWAxns5-GNTjiLVIcn-q-G9zUAdTKJo', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T10:56:29.543765');
INSERT INTO refresh_token VALUES ('3A7R23Q3vysAY0s0xwZ3KpVYgObaZ1Lz9IrXxMUDXxs', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T11:02:39.444513');
INSERT INTO refresh_token VALUES ('TF_x5ZjWSjWDbNxVgGwcpj_4QR_4uIAUWO6gBnhznBw', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T11:07:40.088806');
INSERT INTO refresh_token VALUES ('GpIBbga79XPXLHvEhiMjHGfXZwNDA26Kn0i5HATSUeQ', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T11:15:05.352898');
INSERT INTO refresh_token VALUES ('ceokOVVyN9ZIiEUz-FW6QHHPbB4bOVM6bWE0sQtDt8Q', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T11:22:10.835721');
INSERT INTO refresh_token VALUES ('pOgTeTo-BIJGEVoCrFkUZXuHfuEjijoYOv5Q2XC1FOs', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T11:26:16.434882');
INSERT INTO refresh_token VALUES ('_k5Ar_G60hJ5DV-EQH1r35Yy6kOQLlg3nJP9klgP8fM', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T11:27:59.575492');
INSERT INTO refresh_token VALUES ('miWVQz8yW1pS-SndvF7ZP-GqDA-REeBt3RB53bZAeL0', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T11:31:54.244665');
INSERT INTO refresh_token VALUES ('_wau6o8XgkLbgpzqAw9_X4bSIXrTDLoG1yuUuBpKmBY', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T11:36:34.403931');
INSERT INTO refresh_token VALUES ('61CKMFYXG4_Hk0-Lghtwv2Bflbj2sism1u8bMdk2Opg', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T11:37:21.407993');
INSERT INTO refresh_token VALUES ('2x35kRTUe5Z3H4LtIx0ev_Fve74wATVhhVlQW9bMuKg', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T11:50:56.253748');
INSERT INTO refresh_token VALUES ('45GxjS5LxprqmO0SwjD0jRI52mlsjtCCJvwzAMOYLis', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T11:54:55.656482');
INSERT INTO refresh_token VALUES ('tabDN6_vbTV91qTDPs9xtApSzxAA3iroFdzKPQjEvBs', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T12:17:09.508233');
INSERT INTO refresh_token VALUES ('bUm4l7fFD-RhWA0i1C3g5flzzQikKaOCPQzkM5E_WoM', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T12:18:44.070822');
INSERT INTO refresh_token VALUES ('GFDLPDLbBpK1tQ436NnK5ykOGJ40llvOz4hKyilxUK4', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T12:21:07.619185');
INSERT INTO refresh_token VALUES ('doHfEnc4lN-HEdPyPHypBBnd7xoq2UAjrTz67quGxok', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T12:32:47.993336');
INSERT INTO refresh_token VALUES ('9wucWuhqaqfcUjieOms1_j_ykadBbXNRA4fj76OpOOQ', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T12:52:48.394310');
INSERT INTO refresh_token VALUES ('vQYKevl3auNjavn68CCyKFy_LgcXQAPTj5bHAaLb4iY', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T12:53:27.060950');
INSERT INTO refresh_token VALUES ('FenzKKyIUvthRDBeaRL0hl_ndC8iJKCbJCv0LREPFvE', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T13:05:23.127431');
INSERT INTO refresh_token VALUES ('0yKGCUtP0O7a2vD7r0UFEMQ128N56ifDah7jBbi8ZYg', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T13:14:26.337177');
INSERT INTO refresh_token VALUES ('pbOeD43n-PiBxCv4sJl-Gos9JFkH9hpGkCPrZVGImDM', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T13:20:40.542192');
INSERT INTO refresh_token VALUES ('4wVQSudb9ZR20O-YM0CPFN-lXhOHptXxFkmL1RD39Og', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T13:25:23.016236');
INSERT INTO refresh_token VALUES ('2ldvO1a38tUmml2zzf7a1QVqSdXH5AMEkBeru-NM72M', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T13:33:09.048009');
INSERT INTO refresh_token VALUES ('w72uv4wWiDcvG-a_PyqdmL3Mwh64Qr0cUIfatsh5Avw', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T13:34:00.534698');
INSERT INTO refresh_token VALUES ('YHYWaMe2okVkNb82VfMYxTR54iPRnE2ixJCjynZRK-8', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T13:46:34.556882');
INSERT INTO refresh_token VALUES ('jH3ecgzTOSBj205bjELS5djF1L3yG7TB-xFA8jro72M', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T14:31:46.515657');
INSERT INTO refresh_token VALUES ('EDSNXYSbzLM4iyd3vWv57xGH67EHWONv4UPXKvbwiOg', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T14:33:59.184227');
INSERT INTO refresh_token VALUES ('xkUb2VI2__52x82CzEdClBevz9mJFdQJwKEkcIa6n64', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T14:41:59.218037');
INSERT INTO refresh_token VALUES ('RD4gEHYXBp7-rvb99KzURjV_T0TWoUATPtthsK2oBF0', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T14:49:51.250141');
INSERT INTO refresh_token VALUES ('2SyhQKPsmk9_FCc-ho2BUSB8U9a1mGOXR5L0emp2Km4', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T14:50:16.430327');
INSERT INTO refresh_token VALUES ('MKZTnXSjZgUhHZkZdyq1PEkbBVM-7XGXuhjceFWAeIE', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T14:59:29.074804');
INSERT INTO refresh_token VALUES ('PFsbXOOgBTPFoy4fD2e46SJrtwe_0rTyG3ovigeYRLs', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T14:59:51.232590');
INSERT INTO refresh_token VALUES ('pa1YLhqXcAhPN58cgvx5mzg8zW421d8PFoBNl956hSI', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T15:03:10.150793');
INSERT INTO refresh_token VALUES ('Zcnx4Td6qPnoUDIJN0bcCpjOlBQwFOhwaEacDnMdFxY', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T15:03:46.728900');
INSERT INTO refresh_token VALUES ('cZizWVNUVn3HapHm6pxRkZGqBMS78aXJbKxe-dZtgHc', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T15:05:57.741195');
INSERT INTO refresh_token VALUES ('NNBq3oxEPZwR0cMcsedSKBkv2LeMkhAtguaGYFouBSQ', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T15:08:47.100854');
INSERT INTO refresh_token VALUES ('iaqQY8foraukDr4zyiskSjSPv9T041mmYnUsEggiy7k', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T15:10:55.800521');
INSERT INTO refresh_token VALUES ('LThtj7aAxR417ksBRQ1yW0OriWSnE2oJxxoajhwekx0', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T15:13:50.836360');
INSERT INTO refresh_token VALUES ('mx9M6DW7PoA6e_2jWKozaj7A9OzdYvlqKjGTjzXGAnQ', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T15:14:42.188023');
INSERT INTO refresh_token VALUES ('B-noFu-K8xeRgdZ7DgFlrk5Jqywk-Tpu8wGAkJuqxvk', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T15:16:11.661580');
INSERT INTO refresh_token VALUES ('lL3TtMb7de5Skw9CLvPbzEfkfvcb8W_BD9p2rLJviK0', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T15:41:25.785040');
INSERT INTO refresh_token VALUES ('29l9yHj7w6r8ijx_wrjCpzQUO0DHHqdKjTeTDBdajJs', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T15:42:55.075389');
INSERT INTO refresh_token VALUES ('AnitvS2IFHVKnWJ-FokGOBV1JUFNXd8WeEGpuOJTlLo', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T15:59:19.179787');
INSERT INTO refresh_token VALUES ('b0asX8Ce47rsNC_rTt6SK7baIlJDSoiIO5PA2TsOUfo', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T16:00:01.978418');
INSERT INTO refresh_token VALUES ('jKBQGW8-OFAqWbOD5bnDZTV9Ul6ZpyAoL-yJ79g977g', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T16:25:24.866534');
INSERT INTO refresh_token VALUES ('jBa78OoO2UWEY4sQvGNCw9vZN3rE-LtYaEAhev1498Q', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T16:30:13.839994');
INSERT INTO refresh_token VALUES ('LfWEc83R7L1LSGI0dvOT-iowm9cJJ8Ku0s19CPCeoEo', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-11T16:30:40.184135');
INSERT INTO refresh_token VALUES ('-udu2IFLHrmYOBU2h7NBmXdEu92T1KzZRw4JDqxzeDo', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T11:54:51.558851');
INSERT INTO refresh_token VALUES ('NBpimEqT4lQNYTbJwDRdTk3NpV4XiJw4urmaY7Xahx0', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T11:56:02.024793');
INSERT INTO refresh_token VALUES ('kf4Ygyxmdt-M7119v3CWzkEWf3fnyl6Zl4wMp4MRRUc', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T11:56:44.150903');
INSERT INTO refresh_token VALUES ('M3Ve096LY3IixaiKj4fNjehg-Z0r8bYhnGXajfvbS7M', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T12:01:41.885564');
INSERT INTO refresh_token VALUES ('0J47AQrCBr6X3efwOrgqyfSrkIK1_aqpwiJXBmWy6CE', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T12:12:09.223196');
INSERT INTO refresh_token VALUES ('AGyHYGg0l2Ff-wxkd2-8BiBftf1008SMZf_Xnxq5Z2A', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T12:17:38.963767');
INSERT INTO refresh_token VALUES ('SI3Mms2X5M-1TN0VrrbZ7SLBqgXmqoLTn27LnTR8wKM', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T12:21:47.278302');
INSERT INTO refresh_token VALUES ('M2veTrfLZ1I-JzSNBHwHIYMx7bTbwc_ckGtvSYc-U6g', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T12:36:12.486791');
INSERT INTO refresh_token VALUES ('ds3N41R86pESoqy2p0ZpeFhKEBNkqYfzYl-Y5-4X7XE', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T12:42:53.299346');
INSERT INTO refresh_token VALUES ('0HsaMzxkHZZvwIuQHNh1yTcehata9pfVvJRnoJflXdE', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T12:51:52.712340');
INSERT INTO refresh_token VALUES ('GqGKjf_lT1PIZhc-7chIYir7T61TInP1hH_30WNczYM', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T13:03:28.970626');
INSERT INTO refresh_token VALUES ('xMLKS3x9cnc8mQxcovaCm_l8Acgwi09ulF7Sh4ylrYw', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T13:13:42.291281');
INSERT INTO refresh_token VALUES ('uBwNEuNYB4Fm1T9okJo1mVOhOzc-cvrcyu5J8nJVEME', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T13:25:50.204136');
INSERT INTO refresh_token VALUES ('6Fnu1YzXo84FdinoWnqOuN6dSJx2gTUN-Eh6lDtu1_U', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T13:26:27.874363');
INSERT INTO refresh_token VALUES ('CxgLwL4PHI7HP9mXI9UQWj7orTRD1EzYX9YcGm-Jb0g', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T13:36:25.301830');
INSERT INTO refresh_token VALUES ('7py4JLkQJDtDgm2zPAapVV7YtGY-xIhHL4HK6cNwIBw', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T13:46:06.758097');
INSERT INTO refresh_token VALUES ('rRlHz9aXTw76GW97IcOvBNagsSQqkPBP1ulJORsrYh0', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T13:52:27.025604');
INSERT INTO refresh_token VALUES ('MV4mc8kC4VcB-fRvBA7MVK54pYxBLA1XnsfPDjuD75A', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-12T14:20:11.633277');
INSERT INTO refresh_token VALUES ('Hhuld9umuUfCkZ2SbjnjUmTjcZwRh006sUwlBc3-Go8', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-12T14:20:19.983933');
INSERT INTO refresh_token VALUES ('s5nuR44cxr8YKRcvtG5ZkNh1SFnY8rF8RwtvzRZ8YM0', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-12T14:20:28.930263');
INSERT INTO refresh_token VALUES ('pMzeLy_MHrhEj6dj_czezr7mAw8vYJ-EKrae1A9LOu0', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-12T14:20:35.537732');
INSERT INTO refresh_token VALUES ('B62wmc-eI658iNUv8YgxmpPos576FLCqukdXKKCXrqA', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-12T14:20:56.779808');
INSERT INTO refresh_token VALUES ('uMnBVGLUtPgxWCpFgQ_s_pgPiNvt7j1D6unTTFOf5Bo', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-12T14:24:47.035818');
INSERT INTO refresh_token VALUES ('R50Wc3AIc_UkpmoPmbsZXquASnbNVtiXcIcNANQIoSE', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-12T14:24:56.193725');
INSERT INTO refresh_token VALUES ('FJpBdMK-jliH22W2_J0Jb-WekH9JQ9pKXcG__7S1BSg', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-12T14:25:57.611878');
INSERT INTO refresh_token VALUES ('OlhJ92vvJOBzCDJTrVquRJkCf1_hsbX091xRvttMZFM', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T14:29:36.019726');
INSERT INTO refresh_token VALUES ('HxyAkpSGjR43i_cYoX8QUF3UKFdfDCbQX89Zrm4bp58', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-12T14:36:19.278402');
INSERT INTO refresh_token VALUES ('Te4x3OiMAXmlgjfi3tiQxMhVZh139Y5hB-0E55akAAA', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-12T14:36:35.658151');
INSERT INTO refresh_token VALUES ('x7UTdiyTNEMqHRzeERCY8YOGPcbxjhECxRrQgY1m5jY', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-12T14:36:57.860903');
INSERT INTO refresh_token VALUES ('tAqQQT6lTB0FMXM9lkJfiSN2rg8GivJ9M1H2pAiuAX0', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T14:37:35.410621');
INSERT INTO refresh_token VALUES ('JVbMY4MWF89YiX8ZrQlc4s0V031jPauIkwPKzQ3_nPE', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T15:21:47.773014');
INSERT INTO refresh_token VALUES ('sfauioBRxQhN1J2iC9A35py2rTd3N9yErD_wYQVczvU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T15:24:03.928803');
INSERT INTO refresh_token VALUES ('6iPIg9l3oGrM5CpxT3-A0ITQFkDFcFFdBJTTiFcaYFo', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T15:29:21.247415');
INSERT INTO refresh_token VALUES ('EqWLaH5eS8vs_cT2F28YBfbeC-pi5cIDE5d7FuqSoPs', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T16:43:00.294424');
INSERT INTO refresh_token VALUES ('EE8SgZjSO7C8mn2pRd3FcUJaIbCwal-5MRx0oCnai2g', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T17:13:20.609920');
INSERT INTO refresh_token VALUES ('hRUTntErY4WvevO_tqugPm8P6hbmehFweUpVngx8iAs', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T17:23:22.872861');
INSERT INTO refresh_token VALUES ('XkhKRDjMt7n5-XQ5m0b0fLhznCbbqU-lxOckzsnv-qc', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T17:50:06.720862');
INSERT INTO refresh_token VALUES ('r5OeyCZQiowvLgb2IyAaroGzQObY5jw9Siz9iXn8hXY', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T17:57:04.206759');
INSERT INTO refresh_token VALUES ('ELSbz7WkXw0v12aB2Fc8VtHoZJy24LdlRBnyQLcWJ8g', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T17:58:09.778470');
INSERT INTO refresh_token VALUES ('gB7pcQNTRsWlehi2vVC4p7YEazaY4Ccz1jPhVHmsrS8', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-12T18:15:34.115112');
INSERT INTO refresh_token VALUES ('Y3TbYux1VKIpxrxw5MPxVJGZqp6_1C2DgWxCAF8ck3I', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T11:27:31.197757');
INSERT INTO refresh_token VALUES ('GFQ5R2czmdKfOqlWlGfIcSJg7hehDVNxvih_XRfG2a0', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T11:28:19.727570');
INSERT INTO refresh_token VALUES ('svig-1HWM8JDz6Mhubu0V7T7USuIm0oARirLpSmDBUU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T11:36:36.938883');
INSERT INTO refresh_token VALUES ('-u0Ycab13A302Arc1LgMoMWLek0we2IbpK40cOEd4sA', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T11:57:39.333826');
INSERT INTO refresh_token VALUES ('Zr0w8EAGnDtKNECIT_FUBy_FYn63WR9_K2g1wEqSqnc', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T12:31:59.511062');
INSERT INTO refresh_token VALUES ('ZBlT12Q5Fkbrn-23jONjm9JMg8kzNj2edzeX4K3GvtU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T12:38:06.973692');
INSERT INTO refresh_token VALUES ('03TtXOz-2gqscCYks5Uej8uCjJYpiEwEKvDL-aSMByI', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T12:45:28.733501');
INSERT INTO refresh_token VALUES ('a3mJi8lDDaBLcL_f8AuSVszENRll6Ml9QbUlov0Wfxw', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-13T12:46:10.325721');
INSERT INTO refresh_token VALUES ('bdy2JETkXoZnLik2fHOfe2XT04nleXq8XmFghp2rMww', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T12:49:47.707322');
INSERT INTO refresh_token VALUES ('rCFIIm4S_LENbUkg2b3JwXr_KtP579TCpIDDTkQdGJc', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T13:11:27.099079');
INSERT INTO refresh_token VALUES ('Am6xwk0zRimsqf78Ef_NhzzKVIuedCTK43RqLQUQn6o', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T13:16:15.708210');
INSERT INTO refresh_token VALUES ('4BvC8Sw8ePEhhnfCv2b6BuZ571rTwaUP51W6Rh9SGDQ', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T13:20:27.530129');
INSERT INTO refresh_token VALUES ('ZVRZvQr4zsI-JKEvnDGtTomTsSdv1s0dOJZJhWZNSMw', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T13:22:44.751012');
INSERT INTO refresh_token VALUES ('go0TeUKxqBG_oPKeKVtzIpG9L2aM_jtLY5_I6AjcqR4', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T13:25:41.418041');
INSERT INTO refresh_token VALUES ('ym0peW54InWu1MfW_3HasITjqDzi4FN-Z6hEecr74zg', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T13:32:13.551432');
INSERT INTO refresh_token VALUES ('v5aHzV-dUntt0d0xjUZKWUPRKkH1Y-ZjBqVqUIlAURY', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T13:40:00.536026');
INSERT INTO refresh_token VALUES ('w7qi_vY5oIzbpm8FqNgKmWxkeAHeIHSlPkiAkj2jhSU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T13:41:10.560635');
INSERT INTO refresh_token VALUES ('RxqvBvGEb3EBXkkH1BxMC5LoCgd7jGebor0wf4tIbR8', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T13:43:35.204891');
INSERT INTO refresh_token VALUES ('VkAc-lIoYI8ZKY6E-lkurTDnwcVFDP5LvJOb8-_nbY8', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T13:45:06.729220');
INSERT INTO refresh_token VALUES ('F9S49fyUXxx-_fTwMK5eFuD-RBpYXq4meVpoAckjpXk', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T13:45:15.987812');
INSERT INTO refresh_token VALUES ('nEXaZP6s5Fqcqu25uvFatuhfpwbhXOZBzctR0F7Y2xA', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T13:47:19.728964');
INSERT INTO refresh_token VALUES ('nDocOb8EBbnesGwBZZFQ-lNQc2ZToV3jIuP-k3POwJE', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T13:47:36.522932');
INSERT INTO refresh_token VALUES ('l3ezWoZ8WMgmHpx6b2SMC2kO2jEOKYY20CXXbARurfo', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T13:52:22.787988');
INSERT INTO refresh_token VALUES ('-OcxFs8Jm68PLHclAj35K3d1R3_dQTjAeKpuUIc2yRI', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T13:55:04.956726');
INSERT INTO refresh_token VALUES ('QSYRahw-fI2yuQxqH2Q6wnmSTE46bZ2oZ0prro0fYWc', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T13:58:35.885377');
INSERT INTO refresh_token VALUES ('QUutVS5wBEtTWJp2CFnAG0_Bueyaj8fTa-Nh2mNz4P4', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T13:59:48.849416');
INSERT INTO refresh_token VALUES ('yCiumoBmUTEiMFIgDc3Y8MXUS-AtDnlh8FzUyPx4gPI', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T14:11:04.420192');
INSERT INTO refresh_token VALUES ('0X2bL8fozKNozdqnKNSPm4LJuTYQ59p7i9eowBXgV68', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T14:11:19.095046');
INSERT INTO refresh_token VALUES ('HKwysWSvVxWph_RYhOehpirUURHfy5sazmHNkNi-ZOU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T14:13:47.368591');
INSERT INTO refresh_token VALUES ('PzMLC_bXmr5uWpVJ-a9zIg6QY4dIu5qNWco_Xv3CS_U', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T14:18:09.157921');
INSERT INTO refresh_token VALUES ('OXCXId4c4H9Y8WC6ycAUEK6-w8-Ai4xUgeWgJmP9uwk', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T14:30:15.665697');
INSERT INTO refresh_token VALUES ('mitXPKwui4QbQQU_YijKN06XMjFPaJMnk8DNlyy539k', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T14:34:55.904926');
INSERT INTO refresh_token VALUES ('2kPeaWlppQ7LlEPo37lQef7Yvz8bjR6uHduSpx12on8', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T14:35:14.503005');
INSERT INTO refresh_token VALUES ('YH8p_OmsJWNKR9MWSeUyQni64o6N5GoolGcYgArX3CQ', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T14:38:13.290424');
INSERT INTO refresh_token VALUES ('NFmAtsBtmcBSziRPwHIH3fuPny42ff1mH-xxhStC51U', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T14:39:17.435697');
INSERT INTO refresh_token VALUES ('FfthutaJkcmCo0VQY_XCkz3By0YQM-A4QHGAT6XQacA', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T14:43:24.022420');
INSERT INTO refresh_token VALUES ('V5EtwhWCT8-y578OjY83KrTSt7zP02njos0TdlHaUlM', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T14:43:41.712346');
INSERT INTO refresh_token VALUES ('IoG67_R7mN6SpDkuQE3eodpOSGxvTKKNToFN4tpF_lc', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T14:47:27.282279');
INSERT INTO refresh_token VALUES ('S9LYSEjAL5pT8etG0wxbjnU69Zn-nKdOB1h_HLQKRGg', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T14:47:43.293055');
INSERT INTO refresh_token VALUES ('q178qFGlpsp2emots6G-VFkFjnpT3ew-C1SJcM2E9zA', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T14:49:56.286440');
INSERT INTO refresh_token VALUES ('VrbhphdkzkNvGEol65daX5-u5qso2IsaVvVEIa5_dC4', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T14:54:54.125919');
INSERT INTO refresh_token VALUES ('fhuPVziQmZAqcBchuenbvfSW2UmmKJt9IYaZnM04X5Q', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T14:55:05.994087');
INSERT INTO refresh_token VALUES ('-ME3utdD0kXu6WvRWCGol7Gtsw5WZECZNDGTKscu9W4', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T15:01:14.926185');
INSERT INTO refresh_token VALUES ('2UXVpiSWq149x5Sb-IVnL1n2560FuXBrlUbksCg_sLo', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T15:01:21.317019');
INSERT INTO refresh_token VALUES ('h8LkKdBCuBzC9osDT3pSKUwnid674Tcab_Q92oADSMU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T15:02:54.839414');
INSERT INTO refresh_token VALUES ('XzfVz0fOkSzaOQ3t3AubhbbRKByI_WtQf5DJFylEDKo', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T15:04:20.741950');
INSERT INTO refresh_token VALUES ('5nGnkFkvw1icpB7Y1fGUcMbU2FUFLmxe_JB-ZPnEZMw', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T15:14:01.860535');
INSERT INTO refresh_token VALUES ('msD9-nCJlID8JdFtCvos48gCE1699_Tz2xUAxtV6t28', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T15:15:13.087402');
INSERT INTO refresh_token VALUES ('jNsUUnAnqOSw0fJucyXFG4C8WaXvsoeTHC-mQTu9rYo', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T15:19:01.633955');
INSERT INTO refresh_token VALUES ('hmV28I0BVzby5PP-GoZ-KIFCdsFO22h6CFMTZ8J1Yc4', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T15:19:15.296859');
INSERT INTO refresh_token VALUES ('EhBSmE6vqRqQI79lGeRoluyI-L6pIfKJAJ5QcA_5x-M', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T15:28:49.106156');
INSERT INTO refresh_token VALUES ('JSHtHKtXx2YXi-KnMrAzenoNEThZAfuXpGAvaTrbqgw', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T15:28:57.591024');
INSERT INTO refresh_token VALUES ('lDG86cjkSNVlPKkVKzGWEqRMY5uPNxkXnBOQluGWF10', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T15:30:03.045015');
INSERT INTO refresh_token VALUES ('smZiaG6WcPRZZhsvedG6EqXdQWRxt6laij8ek-2L8CA', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T15:33:25.580405');
INSERT INTO refresh_token VALUES ('wjasPNt7x_8rEqaXRmJj_HHhQo5UXqcoGTqMLXu_asg', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T15:33:43.392590');
INSERT INTO refresh_token VALUES ('kZmyD1_29SqUPJcMi8kzkyy_1bCWikpZlo7GgvkYQsw', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T15:53:54.455600');
INSERT INTO refresh_token VALUES ('3iBR5h_mSqYT6tJPYhFwC4n-UePLcBIqkxw5tv2PR68', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T15:54:05.335559');
INSERT INTO refresh_token VALUES ('cP0LFDx0e6rFKT2l3zbF1LJ6aDAhcw3L3AjjmPeCiSk', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T16:03:56.231278');
INSERT INTO refresh_token VALUES ('bxQOcdc9bLULqFBfOlcK1Oa6FoGcinYy5G6NQl9Jvz0', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T16:04:20.217806');
INSERT INTO refresh_token VALUES ('M0Efjqukk0mbNwDhfUXQSk69MF2qlQSAZIpuIlTPqf8', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T16:06:28.394570');
INSERT INTO refresh_token VALUES ('eF6RkDeh21DwXO8LtbwUwABeEbPf8uYVb9Z59S8jTXI', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T16:07:38.955434');
INSERT INTO refresh_token VALUES ('ZuXUpE8qz6Lan9tzHgAxRJz--RJYUWdrMuBRV6USrjk', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T16:08:01.599331');
INSERT INTO refresh_token VALUES ('5YPgIA9_yJneHze-dR1SIjJCu2EEf4Qa4ATYF7lqMUk', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T16:16:09.563039');
INSERT INTO refresh_token VALUES ('-oK7X_MGSOUbg9fpTlUb73BZVsTqI4oX4NgDnCg1Irs', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T16:17:34.489299');
INSERT INTO refresh_token VALUES ('aMW14yZ7VpUvRE6PfCDwZnfEgKQNEcVOvJKJ0dUg28A', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T16:18:42.012616');
INSERT INTO refresh_token VALUES ('kjj8NPL-b1DJkh3t5fHru9TVR-0G_OpaL1jZ9EL1tWA', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T16:30:51.915529');
INSERT INTO refresh_token VALUES ('fkstPWzbVYIKWbPSMxAxW56Dj-tCM8oJsP-EPVBAzJk', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T16:31:13.656405');
INSERT INTO refresh_token VALUES ('Di1w95yNiSZJnVqyv5uw7OJ4l8qjg1mWNFP5Z_FHhSI', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T16:35:36.245003');
INSERT INTO refresh_token VALUES ('vclE7zbieFI9dZTBFgoA0W4CMJ-wnB1tQpoEGo4XSnA', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T17:02:22.068459');
INSERT INTO refresh_token VALUES ('gyi9coepHzgoW-LPAbulQbtEoET8ZDp2rha2i4hglco', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T17:22:01.089731');
INSERT INTO refresh_token VALUES ('UHLyOJA_o7JPs1l0Wxgl5AZ5B5PyX6xMCQiuoK2yQt8', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T17:26:27.898313');
INSERT INTO refresh_token VALUES ('IhrY0o73U0SmfYNOX16GD9a894sU9AgO45d_JMWmaxk', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-13T17:30:41.505925');
INSERT INTO refresh_token VALUES ('pV3tQbY-XULtN-ByhbxPndcdZkyszVRoSzAKh04rF8c', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T12:19:27.335961');
INSERT INTO refresh_token VALUES ('vxTEK_1bSqsMrqm6__zAQQ91UxZmfTy60JsW9vYHwJI', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T12:21:08.189189');
INSERT INTO refresh_token VALUES ('uRRngLphceCbGaqY0PZkP04iaW7nj7kmYItLCWQZ5nM', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T12:35:42.634817');
INSERT INTO refresh_token VALUES ('Bm7wTBWV7FsYFxxJ6I2-RCv1M5VGuyPtFsWnjwLD5vM', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T12:36:25.500850');
INSERT INTO refresh_token VALUES ('DQOy6nuzslva4I4_cw56ikElIFG1_c-mfkysH_zer3w', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T12:40:35.559895');
INSERT INTO refresh_token VALUES ('4a3SIapXLTvhNJcK4VDYsJyj1I5jvs2NN1iZSOa47iQ', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T12:41:02.372743');
INSERT INTO refresh_token VALUES ('MFAOXh1ylZK8jzn1kRO4f2zC6GsNy7DPbadRUqI6Sl4', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T12:54:24.645550');
INSERT INTO refresh_token VALUES ('_V2gVw1F1-KqA_yiilsLQBtedgv3Dfd3qPB0qYfPnO0', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T12:54:59.575123');
INSERT INTO refresh_token VALUES ('X0lYuw_CtZrpNC1sgYe8wgzh8RMb2GYI85Ngwcgy0qg', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T13:02:11.301202');
INSERT INTO refresh_token VALUES ('avPclqpJQESBuzjpkT7F72wdy679sAUTAwmANPlyDVk', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T13:04:27.623141');
INSERT INTO refresh_token VALUES ('oX84P3FjHpSPIcmpKS33nGsumXbK54MEIOHpgHuMIao', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T13:19:12.777905');
INSERT INTO refresh_token VALUES ('uY1Ef-3DAdIXVVxrC-bsIrN0eXq6Zm7urJ-GnNngSjc', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T13:19:58.202221');
INSERT INTO refresh_token VALUES ('XsdtvaW0IovQqMbieQY3N3axEY0F4ZWJbT6zoB9GvGM', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T13:24:20.881318');
INSERT INTO refresh_token VALUES ('VPSEuVa9GX9RRvomcAzc4RjjLVxXeXr7VMk5ljOLaFs', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T13:25:41.947480');
INSERT INTO refresh_token VALUES ('cjJ9t_AkyFjhIpSYTB9i9T-Kv13hF7vPCOs1x5tZGng', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T13:29:56.777898');
INSERT INTO refresh_token VALUES ('9cZowDzRxXwZV8YntIJogPkLcshFwYgCYHj8p3BXEGk', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T13:30:47.189779');
INSERT INTO refresh_token VALUES ('uTEYTA3SLb8xmP0TZvMaD4UQXUHSHdp1-T4Nnv_RYUI', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T13:31:02.271729');
INSERT INTO refresh_token VALUES ('QUVP_eS5mKkMDGJEMiSSd5AJ38W_1oOII7Z_1IgwWsU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T13:33:49.794181');
INSERT INTO refresh_token VALUES ('71votYshq4GOKggT9arSklCHNTVixv2CK7-Gn9z7nTk', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T13:34:10.437511');
INSERT INTO refresh_token VALUES ('ut1zL4OW85rvzFf6dnFQrYNmIWGLj5ckcjkc9oRUMT4', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T13:43:13.705873');
INSERT INTO refresh_token VALUES ('a0Ft5PV3H2EOgdi47bQMZ2stXQBctddjKWrMw3xlOdU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T13:47:58.939263');
INSERT INTO refresh_token VALUES ('U3jmr0EG97p6BHgmjEnWSFjjIHiFhaMa6RWCwfpHTls', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T13:48:26.765009');
INSERT INTO refresh_token VALUES ('NGNG4C6UvxzLqxUWKBJ33E3vSX2ipmikK8CaSIEW6e8', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T13:48:59.642007');
INSERT INTO refresh_token VALUES ('PR_9YYukiwDvFm0rrnA0XS6y0FPEbU7eaLOTPmxe1VE', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T13:54:46.256183');
INSERT INTO refresh_token VALUES ('ZY7XnyLq5i25PoduxrBbBxqJpGOAnzRMkrdLWclx84c', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T13:55:05.283704');
INSERT INTO refresh_token VALUES ('v_pzi0OIwOzUvM4yeFdMRjKS3rfuQLwlibyp4iRRZ4c', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T14:00:32.052195');
INSERT INTO refresh_token VALUES ('zAEJrZdw8YgtPZ6CfL-XUB6cR9sUdmE4P-ibcTvAxhc', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T14:01:00.747787');
INSERT INTO refresh_token VALUES ('ITsjBPQU8yb59WHEmVeU46BYQrtXPpqKlFvUqCKxUgY', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T14:07:36.135250');
INSERT INTO refresh_token VALUES ('HtYHsBrDFTR4hW2gvckJ_e2C0EkBFxwM5ozpYOcOUKY', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T14:07:54.171758');
INSERT INTO refresh_token VALUES ('bSNeR78zy_XI2Y14G7I6bGTJ3cIRbQOHeDE9tZXhlTI', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T14:10:33.285769');
INSERT INTO refresh_token VALUES ('3xJHB443tCIVKU--p70Oi770jxPDgfyujhx8wjotqpg', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T14:11:02.391598');
INSERT INTO refresh_token VALUES ('jjzBdwxWvdlzXEvQk5ojGk-WVcWp6ItNCv2ww2g-uzc', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T14:15:22.180039');
INSERT INTO refresh_token VALUES ('fqfgnp_wc5LBD3HZEiLnUzv_5WrfcIcm_slFrGrib00', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T14:15:37.286192');
INSERT INTO refresh_token VALUES ('BGe8rpjcot9P0aUiEaH2VVy9m-CT8KIrwOdT6C5v_9c', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T14:20:33.146346');
INSERT INTO refresh_token VALUES ('lXMsWoGzHKgdmmSZ2WrbFIW1_XlUIzWO6HyxO_Bne-c', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T14:20:50.032038');
INSERT INTO refresh_token VALUES ('4gMwnB9HkGQM-MVLO6dACLvRO4EeybqU3_VFXZKIqlY', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T14:55:09.926889');
INSERT INTO refresh_token VALUES ('MKMMLPbiNR45LzgG8asWbb6PYsucTXDa2ze0yvS91qE', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T14:55:59.973140');
INSERT INTO refresh_token VALUES ('NK36DC0qht1bc0LQpLkaZr_G3ZFLygggoTQ0iHwB2k8', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T15:23:23.608170');
INSERT INTO refresh_token VALUES ('SLMSAE9IRAWXLA2SF7kCFcdvcmmmAAYGfqeMetjbhtM', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T15:24:58.165454');
INSERT INTO refresh_token VALUES ('r-R0vkdNG8Y4X8XI00RjKfSHJAsS94oGFp-R_-SHWp4', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T15:29:56.602127');
INSERT INTO refresh_token VALUES ('tFWWYJz82HMP0MsR6JYNtiKaryZmchr7yOd2wEqnrVE', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T15:42:41.451718');
INSERT INTO refresh_token VALUES ('o2wpNnuAfgrI1TaMgTxIDcszPvzAhVN7ygwOountmJM', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T15:43:39.292228');
INSERT INTO refresh_token VALUES ('vjB4F-U9IpZlIMpAduqD_GxYAMrOKK6sGZXn91IO9IE', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T15:51:19.630486');
INSERT INTO refresh_token VALUES ('vL9EJRLzWqqFCphA8kH4QJevbLChD_qkxjtCIPXuJvo', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T15:51:45.307228');
INSERT INTO refresh_token VALUES ('8KmELK4KBanJdRitMHsc4krZ0xo1K0aF9BUdwWwHMwQ', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T15:58:06.653179');
INSERT INTO refresh_token VALUES ('H_L8OfTcbHDMZyRxQ5JniZcj67jTww66l2qeM1WdO9A', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T16:01:59.854080');
INSERT INTO refresh_token VALUES ('26ZaA1DLmllct4_5TsqXTGIiChqxBXtNNMO2SWouqGI', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T16:11:20.732921');
INSERT INTO refresh_token VALUES ('5hbUboCJL2hIiLlrI7XuwuBBjiKdQeW0H8aN0U7hIC0', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T16:13:00.060386');
INSERT INTO refresh_token VALUES ('xSvMqut7cP6vfHjuFyFob1V1VMBFmwuBDOC6K27onyk', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T16:14:44.194897');
INSERT INTO refresh_token VALUES ('FGyuy8a9hAY0HvSsgGqUsUEAKmtacLvUgJ8vYV5pp_I', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T16:29:18.604721');
INSERT INTO refresh_token VALUES ('hWa19eifDdEvwEOHuSJRbTLC-qUy7OBux8QfaseQ8V4', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T16:36:01.487570');
INSERT INTO refresh_token VALUES ('EyeP6LM71vyXb1TpT7GwqESEeghZXYmle_bZLXLi8OE', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T16:46:52.725618');
INSERT INTO refresh_token VALUES ('ReINPal6i1xt3s6CyyP8Z79x09i5hkvjeOWYl1b-zO0', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T16:48:39.847099');
INSERT INTO refresh_token VALUES ('K8g4wExyS75HykmhMx7mlt99XsglUJ2TL4xyk2EcULg', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T16:50:57.377022');
INSERT INTO refresh_token VALUES ('NQRu3h7AAmlsjDS3qiBzKg1xT2YxpPsbUZoa0BV2vOs', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T16:53:38.634083');
INSERT INTO refresh_token VALUES ('wuwv3E3AWNWW-e7SQW5Fv015cnGZBJaYm-fX81v8FN4', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T16:55:06.091618');
INSERT INTO refresh_token VALUES ('2MmGsytRIIUNDSuFS-JZscv2LcLjrFMzCoYKmBwLd-Q', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T16:57:25.337950');
INSERT INTO refresh_token VALUES ('bS2JgimIlr5b-t5GxQU6LfRIIdSA93Z9VdilP641tTM', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T16:58:29.532112');
INSERT INTO refresh_token VALUES ('noHXVJnYKokgdeMDLX4kmRhsOpAuyANXfJxjxg84920', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T17:06:09.130670');
INSERT INTO refresh_token VALUES ('mYMOUMEoAmp1f9nVrtd_cXSwLwaZ01KGH-Tjog1Xfm4', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T17:06:51.788923');
INSERT INTO refresh_token VALUES ('WiE9uVZoNwVmwoXYmR1yLuecAa5PFznQ5PHvmeVgSGo', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T17:08:29.814737');
INSERT INTO refresh_token VALUES ('ukAiuI4BttSaKZ5bIb-TQMY6DxiJsn9ffWVaZzU_xeM', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T17:10:50.880162');
INSERT INTO refresh_token VALUES ('SMWzoVJN8jJQ-WFvRr1GujtvnHgieVHjDnfrDSVFc1g', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T17:19:34.766675');
INSERT INTO refresh_token VALUES ('XifX0Oq3ieUDPa6WmBPZAgmca4csSF8234oUTchfRfw', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T17:21:53.741127');
INSERT INTO refresh_token VALUES ('TaMJ3Or6UQrE51q1narakUOSowzhZOu5GFS5WLoVSXI', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T17:23:37.108513');
INSERT INTO refresh_token VALUES ('amnS9dJIooKoYczN1upP6gyUKs-MDc7IIl7sI0OTmTk', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T17:25:16.908436');
INSERT INTO refresh_token VALUES ('u8TYzHv_dY0YYZuV-L4kueFr39Azh7XfJWF3soMIuU0', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T17:29:06.839984');
INSERT INTO refresh_token VALUES ('o2I99nTDMiR3VN7BRBrlWanG2EQr6OaKjItsbHFgK4s', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T17:31:50.287183');
INSERT INTO refresh_token VALUES ('S31E5OVfcPfl8ZMaRobNYzzQu-5Tioy-PwbjuA6r2fQ', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T17:33:05.493624');
INSERT INTO refresh_token VALUES ('lcwJStAkK1ba3SXWeBiIosCmm-Iu4dW6n0INpBifvKU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T17:35:40.041153');
INSERT INTO refresh_token VALUES ('AS-tFrheHipFl5zh4k-hd3LsBIdl1QNuvNIo5rx1H0I', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T17:38:28.080013');
INSERT INTO refresh_token VALUES ('119ta1-_vjRd_Sn7KUaJVeVPxBu5V2CBq7oKaj7Eyhw', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T17:41:41.643895');
INSERT INTO refresh_token VALUES ('5JVqbmur6dpwi5vwRqFNCmM04uEnDS1F3IXcjLgEuZo', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T17:46:44.935209');
INSERT INTO refresh_token VALUES ('sqXJ7J2cP4YoO_nZwCyZmfa7OGVynZ6KvqQk92a_4RU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T17:48:53.299877');
INSERT INTO refresh_token VALUES ('ZeJ2kMV8hZTqdBMks9FX6_WPtA1Ur7JHS-tB8CT4t8M', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T17:53:14.580182');
INSERT INTO refresh_token VALUES ('kXWjMXKF-MhNsNWegMtfX-3DiABf8OHUfiF_Gdd5PmQ', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T17:54:57.278397');
INSERT INTO refresh_token VALUES ('NWWBoAme8wjGMg9AvvzpOM4JavKiIXJAkdCTWDObRYc', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T18:00:06.837942');
INSERT INTO refresh_token VALUES ('rsrt34_BkPCCDeIABdhFr98A5so7_4dXkLqROXE3OVk', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T18:05:22.293948');
INSERT INTO refresh_token VALUES ('CRXhb065MRHXkJyjMgGIFGE01i1Qs1UFry5zQfDQQfA', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T18:08:11.293319');
INSERT INTO refresh_token VALUES ('pkBssGrWvLo3aPgLEo7I0pxVG91faYfEFpENmgLnTCU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T18:10:16.399700');
INSERT INTO refresh_token VALUES ('R_M7Vt1rDE3Q2lm5IFaG6S_72ZAHejiXSVIvfvQ1r9I', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T18:11:33.884215');
INSERT INTO refresh_token VALUES ('RksYtOCHfrWH4w5Sm5-qaE4Opa_YHPOWCPHmOD-C0x4', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T18:16:01.544157');
INSERT INTO refresh_token VALUES ('mgr1GvC9TLxCMCHDXx7Wd0HYs-DeLiuDpHnDlCwCx7Y', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T18:22:47.451569');
INSERT INTO refresh_token VALUES ('wL9XVbU9tMqsRdQfZi2So07HKk8f2h5d7cLGwePW-Rc', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T18:32:28.796666');
INSERT INTO refresh_token VALUES ('9aHZ6ItpILMJV6EldoY3qDn5ToR9xnBfBzyPTEYSNJY', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T18:53:43.759604');
INSERT INTO refresh_token VALUES ('ZjiOrQogKaYcYbm-Am_CLSdVUANlbhLqgcz-aq7tPxU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T19:01:33.709577');
INSERT INTO refresh_token VALUES ('_zG1J3hNrf0jtCudpBuHBKFU5b5gFkTyDBDRKnKWB8c', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T19:26:43.486339');
INSERT INTO refresh_token VALUES ('Ts04pnsa3A8GUzpMzNYJii_zMejDAPi9o4nqoEWIDeA', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T19:32:39.074344');
INSERT INTO refresh_token VALUES ('Bkm3-G2xRQTXWkr3aE80_CiNrtWs__qvA_YkDnnznP0', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T20:48:21.759243');
INSERT INTO refresh_token VALUES ('kAe5jFEd-zui31VsbNlClAg9semJVPKmLp3VxPlNjnQ', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T20:49:30.634913');
INSERT INTO refresh_token VALUES ('v2LesxAxDpiK3FOoF83yooT3yh7PtY4jUbeYqvs98bk', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T21:00:12.550118');
INSERT INTO refresh_token VALUES ('qrd_0iv9MFm_Ax8B1jpBkKioqNgeVhi_Wg5H6B1vSl4', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T21:01:40.297324');
INSERT INTO refresh_token VALUES ('-oCXxF3qwF5SR6xW_SUeqVZsZVuGyDlm4hqb9D-Xr3Q', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T21:04:47.683244');
INSERT INTO refresh_token VALUES ('YJsqYJucEsmFgWwMhKjEo_bA1m9vt2cVNDjDSFFnSZo', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T21:05:22.915304');
INSERT INTO refresh_token VALUES ('LAn4hC47Q-wZV9k3bcUsP7DM2u1osOnsm6RroDVcY7I', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T21:07:59.069086');
INSERT INTO refresh_token VALUES ('_YD9zzZaMwqM7e73MokKFbK9FyDT_KTg6ETjsT1g_bs', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-14T21:08:26.102604');
INSERT INTO refresh_token VALUES ('sN5JiTv9DlfexdVNVT0yPG_4BTEKHTLJkqNTbLkWOF4', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T13:05:53.639406');
INSERT INTO refresh_token VALUES ('kNmezcJHBiZWqdas07xDsnwEaceYwb-yLocNQnwiIEA', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T13:06:57.997823');
INSERT INTO refresh_token VALUES ('4E__eWpNWCPcPk2QsjQM7junyMar7GPHz4YkTLvRNQA', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T13:25:12.971929');
INSERT INTO refresh_token VALUES ('VadDvUhpnaVpTVCROEEBNdjul5h-ciHwfb9dz6pD84s', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T13:32:17.007885');
INSERT INTO refresh_token VALUES ('z85I1jOeh6T8kvZGmhlgoGzCbjJ0ynb_74jxwzYZc1I', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T13:33:24.064946');
INSERT INTO refresh_token VALUES ('b5HbLwch6lgUsBe0rWYLav2dtS4izNs-3VArS42Qk0s', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T13:34:37.904511');
INSERT INTO refresh_token VALUES ('7jITwgIcDRJhD2Ylm6JdaSEzG1DwO2CL9SbC-xzaqQo', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T13:37:05.250696');
INSERT INTO refresh_token VALUES ('Ww_DIJniej1HSRnGKXC7Re9GtxkWlZyw9czsbasYHQE', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T13:39:48.171668');
INSERT INTO refresh_token VALUES ('r13sjmEfqYvdt8sMLmPMBNSk9uLzIZaZoqdEtz3_Pfs', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T13:49:39.964233');
INSERT INTO refresh_token VALUES ('F7FEVrFYQ_vzvmVV_55FRKNnX19bglDSqzrUtQXKj_U', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T13:53:01.290996');
INSERT INTO refresh_token VALUES ('0V4aRmr6IvF6OPG8SRE0AfAFmdz3rTXDXWvDuEXGB68', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T13:54:07.049107');
INSERT INTO refresh_token VALUES ('sHmBgqo2FZa6yzh_-TT79HPZAQb05cRTjU8m7sMOJaY', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T13:59:02.056023');
INSERT INTO refresh_token VALUES ('RA3Gqt7QJP3PBQLYZwnzucmMqizGtetU-gj9AISKcnU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T14:38:37.223036');
INSERT INTO refresh_token VALUES ('e-_FXI_ZMzZuiN-k9Wlkw3YtMBbywIcUgBdgsbY85Pk', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T14:49:07.877693');
INSERT INTO refresh_token VALUES ('-6FlebScDKaSkXDb3P5WxU3a-Um1dLOYbCZh6WCNO60', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T14:49:19.296856');
INSERT INTO refresh_token VALUES ('BpQQXAPVhZ5uKu2kCpsJPpbjZlnk2QRgoREelX7CtGQ', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T14:57:04.313660');
INSERT INTO refresh_token VALUES ('PvEUBA6u_0vSfJcb0UGurBloyaeaLluS036r_L8vX2w', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T15:00:56.597283');
INSERT INTO refresh_token VALUES ('3fEnXgP965gJQ0kR52-d8EI1MvhqOLEUriam1zamMM0', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T15:04:28.793313');
INSERT INTO refresh_token VALUES ('yZNWf_07CgxIBl4IJua5Cq0qmCU4U5L5eGAu-75OXs8', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T15:09:26.505488');
INSERT INTO refresh_token VALUES ('zAMk3H-I7ULEHC9LLJv7qwZq7mc8V-Eb4wkjL2eTo8o', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T15:12:54.146674');
INSERT INTO refresh_token VALUES ('_qDrUfl_IsdTfMmn4lJ3BfKWd7uyLI4nn_5tji1KEzg', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T15:17:47.063258');
INSERT INTO refresh_token VALUES ('ceQkAl5gRr1pJgRW7Lp5A-_Ygo2DtIX-mxfgGPp8m9Y', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T15:21:50.526994');
INSERT INTO refresh_token VALUES ('bmtnVcj0m9HnHudLyCHWXfRFfq0T_kCGzyIqbaLVheM', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T15:39:14.150058');
INSERT INTO refresh_token VALUES ('8tzF7jk6lo0t4tbYvSVHMpSI7lnfKQb0vBBAWrPDuYQ', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T16:06:04.787079');
INSERT INTO refresh_token VALUES ('_E1kg6KLuILZkwltQpe1NpxqkiKGLS70StZWRpuK57k', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T16:09:26.029273');
INSERT INTO refresh_token VALUES ('fIP9oJAR85jDa51eOUkdzM-5ViBAyIazEC9ZPzIBrLw', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T16:11:30.626790');
INSERT INTO refresh_token VALUES ('_mfCdTKgmMjBBv1ddtYbKBLKlPR3BY3pcqTXU_lxoKE', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T16:13:46.762749');
INSERT INTO refresh_token VALUES ('GfV-W8V1inf4S5W8eq1_pirAaKorhkKmLnA9HUBB_qE', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T16:16:23.400832');
INSERT INTO refresh_token VALUES ('csjSUJByIHdW-4ArRoOrLz8rBOq7zFZPWQWBHQ5qFKU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T16:28:30.088236');
INSERT INTO refresh_token VALUES ('pOiQeNHqYWYjCdXKdy4J31_ud5J2BQuoc3Z8Nc5OsRk', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T16:45:20.380350');
INSERT INTO refresh_token VALUES ('sRbUmy2d8f4fipYuxMQxnJqqsLFW9IhhX47W2Ipsq-U', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T17:44:01.534171');
INSERT INTO refresh_token VALUES ('IcmMoIgEVD4kr1-Eve4rraMZSIswxFRPSLmNfxWpy5E', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T17:44:54.771651');
INSERT INTO refresh_token VALUES ('E82zrVhrxUbE6aFOS3WQ3D6Tz1EvWa78EqhjFYegJHI', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T17:45:35.450279');
INSERT INTO refresh_token VALUES ('sP94Gj2n5oVCJlhdCtmyVKPUEhwgl4UMLy3klcX4KUw', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T17:47:36.508161');
INSERT INTO refresh_token VALUES ('WLprMkw_pKtBAAn7RoBx2zGZMHhhXLH79qSnrHmQOxc', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T17:48:12.549246');
INSERT INTO refresh_token VALUES ('MLivu-r1QEj0nOvUBrem-EmDofKd6hD3yYh6nlm5SgY', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T17:48:51.901410');
INSERT INTO refresh_token VALUES ('HsxMEvZ7v0oKRVsDYP3_dQLpOzujJqOEzQvenMNmPeQ', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T17:49:17.975560');
INSERT INTO refresh_token VALUES ('mA6vHzdVrYWaL0wvovyahYiAc84IGSp5aXTDt3E7VTk', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T17:53:06.261629');
INSERT INTO refresh_token VALUES ('EitnCu_bAWXpzlkK6vOiutInLGeQEGz5RSQJpiqO5xQ', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T17:53:34.185203');
INSERT INTO refresh_token VALUES ('sNMr3rML72SgFaDq_so--1-z9qRECfhOPM4CPEhS4Vc', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T17:55:31.589339');
INSERT INTO refresh_token VALUES ('j0gTQfD14xrc_ypfPJwYd1PmVgiqpBBACZj5dlo3i3I', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T17:56:49.386983');
INSERT INTO refresh_token VALUES ('dCLwH511gTrZ951Tm7yyGzesyK8z5tV_RkzBTwuP1RU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T18:02:54.830857');
INSERT INTO refresh_token VALUES ('YQUv-rt56MFkkD11LNBxVLnreoMgMtJsaDGgo-5Omc4', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T18:04:16.308448');
INSERT INTO refresh_token VALUES ('GBCmUocputbschZ95NAgsXf4q9MHTQ5lEQ0aXwnJ-g0', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T18:06:33.565740');
INSERT INTO refresh_token VALUES ('_Ysp7o3NMy6r0trRG2A-xaIvxCLdr40VZx3afU84CNA', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T18:26:40.550148');
INSERT INTO refresh_token VALUES ('83Q6z_FqQt8EWEsHUwL0FbY40XQlrJlU9zDNqba8bd4', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T18:28:58.898593');
INSERT INTO refresh_token VALUES ('VNlLrhrJJ1AJXK1eIqcsR7U3WMRvQqZzzNVT153RP0Y', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T18:30:28.584136');
INSERT INTO refresh_token VALUES ('dQh1hmFv_20FM-oWYH8-Utvh-EpmABO1KqesuQBDDRA', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T18:32:02.611792');
INSERT INTO refresh_token VALUES ('Wxkrty4McAsY76MEzl5xwD8Kh5dDdVo0lw-YEVnheYM', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T18:33:51.661071');
INSERT INTO refresh_token VALUES ('PYo6JKXpKozJdxuif-4tAy60zU1AsHW0ZnddhXDGgEQ', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T18:41:42.583068');
INSERT INTO refresh_token VALUES ('QQo85TiUSJcek-EkWy4Y_tr0ex5wEJkh6WpYPfaTykQ', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T18:51:17.323256');
INSERT INTO refresh_token VALUES ('sJ7oNmY57NB7z_uyF2iFNAWqkF9fyIsYlCFFIfxQicI', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-15T18:53:20.115045');
INSERT INTO refresh_token VALUES ('vV9QgBnB3oafRMAyWkBVDBBSRzAYY7EqjopnVS4IEUE', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-18T13:19:31.123474');
INSERT INTO refresh_token VALUES ('Ljqg8Tn_7MlpOMm3MD4ax1xfHP9cj4s56a5ruagwZXA', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-18T13:35:45.070604');
INSERT INTO refresh_token VALUES ('IXR-kSOoXYFYsaGIJpQgjht8r_r8z5NXBad7Fp_tgdg', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-18T13:41:59.576388');
INSERT INTO refresh_token VALUES ('MjGPjWRrQlQF9wLK0fcCFFcN1ShNPmewpxqYmqM1Vx8', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-18T14:10:58.553695');
INSERT INTO refresh_token VALUES ('t0oBOmmVHz0UmFF2xGzNhWWpIWy7AJztcfPBKOdaiko', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-18T14:28:09.817617');
INSERT INTO refresh_token VALUES ('BZpGWKz8teeJJzgkJRWreRIp4DtAn24SbdQen9q-hxw', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-18T15:02:47.238246');
INSERT INTO refresh_token VALUES ('Y1fOIO5JWKw7DkcGS-_mJwciHwdT4fQnuoiWvptruv8', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-18T15:07:20.753926');
INSERT INTO refresh_token VALUES ('UTNIXpVC_repHxBKgwVYXmOpkhOLSJxGrfNLgQ_p44o', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-18T15:13:20.276748');
INSERT INTO refresh_token VALUES ('DQb7xAYWpy1xrt0qae-JwaiWq6gsR0LJCdUd1F9u-TQ', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-18T15:31:50.744572');
INSERT INTO refresh_token VALUES ('hESE8xYgO592B9QVn-d6bPp6R2aRqQDSeFpQvlSHFNw', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T13:16:54.241380');
INSERT INTO refresh_token VALUES ('TDTioCap7uVP74oxRM9r20ij0F1pA9MndDzToKrTTc8', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T13:18:01.911726');
INSERT INTO refresh_token VALUES ('b4p0pzuOJDrOIKLVm1mLATsMA1MEeMnU-B5iMgkLvnM', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T15:38:49.035962');
INSERT INTO refresh_token VALUES ('eSgTWfrx60ArMsd9mp__5aPkcGi_HpMjgixWfD9axeI', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T16:28:03.460345');
INSERT INTO refresh_token VALUES ('aLkFPHRVQBbMb2iSGCnVYeqjA9r_Hke7qr4AvKnbozs', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T16:34:36.252959');
INSERT INTO refresh_token VALUES ('S_5aIlOhb3ZkPaTbDrFROawKFO5b-naSqlIFFwuvDOc', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T16:34:55.683143');
INSERT INTO refresh_token VALUES ('MmdJDyBkrc3i_knJi8bgDEN7wtM1SDbpeACsTc6_UJU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T16:46:56.022568');
INSERT INTO refresh_token VALUES ('xuKjJ3ouzKWtqmAZWmOmN8l4vS2d6kD1mxHBQDj0fE0', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T16:52:57.579906');
INSERT INTO refresh_token VALUES ('vYsBaNNAA8nVbqoIiR61MwbHKurXcPgwBjQywUmYm1E', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T16:55:30.959699');
INSERT INTO refresh_token VALUES ('9ycK_V2ySlX87eo2wJs8SFzJr49frT81aWjupGjHv_4', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T17:04:05.623374');
INSERT INTO refresh_token VALUES ('4VP89Q3eclMOIzT0rGskvKMQMdjcpX_4qXUP-iZj484', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T17:26:05.968178');
INSERT INTO refresh_token VALUES ('lu6LGv8AW5A6uVFfLaLUjTZGJT30ydH9-kZaRwzlkDk', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T17:26:30.956050');
INSERT INTO refresh_token VALUES ('ReKaATYY9FUVoJGV-4I_MFOHt9cE2JR6LCOIGI8aU-k', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T18:33:29.211500');
INSERT INTO refresh_token VALUES ('r2tR_cz7S-ne4o82z6ChDzZngz6VIlrji_8KEJiRVU8', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T18:40:47.114687');
INSERT INTO refresh_token VALUES ('0LgESKKA6kXk7WHG5vymvzmq-_lhZKuVh09GPPex6OQ', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T18:46:33.337595');
INSERT INTO refresh_token VALUES ('Qgxsv-78ujqnn-vsXmOTvzcUICZE7dX0SfXi7GKA724', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T19:17:30.801806');
INSERT INTO refresh_token VALUES ('xTZZPeWndvZnywEPp5MmrOntVDu0QaI5mrGhhHvCyxg', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T20:37:40.463514');
INSERT INTO refresh_token VALUES ('8ZiOIbXkh5_autRk0hFpQur2mnikXvzr8BEnbLyGhtg', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T20:44:25.329286');
INSERT INTO refresh_token VALUES ('8ul1RNp5QWpGKC3_filgg1QkuiCACiMZOnIS-OiGxqg', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T20:49:52.042326');
INSERT INTO refresh_token VALUES ('pPsxC5Pva1haSSlhuOnS5yTijM0UKApI55WOxIY2pHU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T20:51:01.433853');
INSERT INTO refresh_token VALUES ('umBmMRju74z_ZchOKX6LL5AGf7xbUfVxiV241xCIOKA', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T21:11:12.526962');
INSERT INTO refresh_token VALUES ('4DwJHKZi6Nl0ivA76umesVcllfgD5vdv_gMiK8fVJeU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T21:14:52.808901');
INSERT INTO refresh_token VALUES ('2DFLOokYpmRGty6L93RpX3-Q_7vVNQULMnGGroYUz4Y', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T21:18:25.561124');
INSERT INTO refresh_token VALUES ('-O-dk0bNTTOZgf5SxYDtSyJ14LScNcNfpB8GTKxO6Sk', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T21:21:34.521517');
INSERT INTO refresh_token VALUES ('gLj-uIkpL1fMpIn_YEeWYQ4W7ocK6-0j2TjT6PioO8E', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T21:22:20.416241');
INSERT INTO refresh_token VALUES ('zftkBCo6Xmjr1aiF5zVONdzred9JfmFDGv6moxuIyDU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T21:23:45.323643');
INSERT INTO refresh_token VALUES ('LOl0ykHrydT0QlYPYTcaM9aNuqvEHj7U6mqKb1dOSqc', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T21:27:50.276997');
INSERT INTO refresh_token VALUES ('5AA3r3mpwTJs6BX9YPKoHIzBWUUAC5Tuccup_MDS1lY', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T21:33:19.669729');
INSERT INTO refresh_token VALUES ('EwFZVD2nSZFjbgeXcfa9RYg6ODlI-CqSFog3D7xY-Q8', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T21:34:11.615879');
INSERT INTO refresh_token VALUES ('K3bMlfyd2hIDyQiVo4MGsa-QGtOTJcsU988G7cLPQdM', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T21:39:06.316987');
INSERT INTO refresh_token VALUES ('-rBSKQTS-d_9lFzXLNBb4eBhtrw942wszBQY4NaB_Hk', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T21:39:47.618108');
INSERT INTO refresh_token VALUES ('hBYk3G2WiPzXRCFZ5-cxVPIXLszZjBRLlES78i21_TI', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T21:40:50.082106');
INSERT INTO refresh_token VALUES ('qqpNAzTiAgi8nKSql0uDtHY08M8i2zJp4qwlg7Drkyc', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T21:41:52.292378');
INSERT INTO refresh_token VALUES ('sIzSBn5bHQ9ZeiqUHZAYZnmFVkVIN5pg_UIVh4-PQrw', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T21:44:12.296741');
INSERT INTO refresh_token VALUES ('KZ9bYajApbjwErKhjslxX0HNXEI3qZnVWRyD03rn_yg', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-19T21:44:47.535524');
INSERT INTO refresh_token VALUES ('e0yyeYD_9-sCtxUhgDjopPhh0VqqxzN65fO8Z87ENXo', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-20T13:30:41.656970');
INSERT INTO refresh_token VALUES ('rZ6Qii1emTDSWyiKypdzzStiBE6G9gqAicqwoD9TJAc', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-20T13:33:06.073650');
INSERT INTO refresh_token VALUES ('yV7TnHaeLeZ_RfGZMIi2HZkFrdLZJnuSy2NBc7hm3ag', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-20T13:57:58.455688');
INSERT INTO refresh_token VALUES ('o3Hu3W3DFMY72Tzbg0upx-awWbibDALtVMb9gRFYp7I', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-20T14:02:23.868700');
INSERT INTO refresh_token VALUES ('skE_JgZIu1COnem6sAiCz4pAHOZlx37UG-avTQdUr1w', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-20T14:05:56.863019');
INSERT INTO refresh_token VALUES ('33ZYC5v4rNW0Y_XCKRcuXHRlRDNc2Bv4aYFhxFox4zM', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-20T14:09:47.841991');
INSERT INTO refresh_token VALUES ('M9W-gNT1Rr0RlANlPIucz3e7kT7IMcNTLc7G1r6Mcz0', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-20T14:13:26.199553');
INSERT INTO refresh_token VALUES ('RtuduW-CBTV1XMaL8KO0dsUndc6F9iqLyUmrqHq6MBs', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-20T14:20:17.501022');
INSERT INTO refresh_token VALUES ('6-99lNGVcDL7EEwcfrYgLJ_yObbltPslWk7fvRgu72k', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-20T14:26:03.702664');
INSERT INTO refresh_token VALUES ('7piXVwAYmZBhdCIecVys5CFe3oAIBOtmOkmQ5D7szRU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-20T14:27:37.721877');
INSERT INTO refresh_token VALUES ('9T-9l4pc-TEaC3VmWx1p3H5wV3lj9RTARfwfGdzat9o', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-20T14:31:13.579378');
INSERT INTO refresh_token VALUES ('7VCXDYvwfEvJALGk41rdBCrQ0mzCSmMuBazxS9UQfB4', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-20T14:34:46.697306');
INSERT INTO refresh_token VALUES ('3aiTkcA6OLA0BudOsIgmWtSfOYOC-bos5B_SsIwyMQY', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-20T14:41:38.031733');
INSERT INTO refresh_token VALUES ('ALdhKKYwLn_SIKfBdI5rj85B85o3k5ZIthHNbLxvzu4', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-20T14:42:14.664979');
INSERT INTO refresh_token VALUES ('eeBq45pnxTU_sYt9x-xcNFUJtN_a-bNd1ccZiiLn6iA', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-20T14:46:47.198484');
INSERT INTO refresh_token VALUES ('VqtuK5EdReGbcy0UNzeos5hPDRYogJVliOHfe-QP0RI', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-20T14:49:26.887220');
INSERT INTO refresh_token VALUES ('HLBDxvkSsTAnk1QsEOfQ1b1kBpzre0T9c-lR4bc9iM0', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-20T14:51:12.705854');
INSERT INTO refresh_token VALUES ('jz7CpLtTdwIR1MnyWGlPOGjkiZY0HD_ggLp7Pz5RQZo', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-20T14:52:55.172726');
INSERT INTO refresh_token VALUES ('Q2Rn9W0FoxxbHYU_4fivJ6pJcDu9hCVh8tjukOSQWVw', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-20T16:20:04.826026');
INSERT INTO refresh_token VALUES ('etyRCP1B9eXOmb3Lw90QenUTkpBVlZoCjDGP5rhM_7c', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-20T16:23:04.261516');
INSERT INTO refresh_token VALUES ('zareyNDsrNYDpiJch7ExRAbnxBT0atM5rh1dEcevze0', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-20T16:26:19.604361');
INSERT INTO refresh_token VALUES ('cA4tPA51nKkge8fpRvickh3vXiVHN-jMeJnx3IQ_QIw', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-20T16:46:33.290481');
INSERT INTO refresh_token VALUES ('UXzdf9Sk3murwfSsi4w3_X8ADakhvwxm-Gq1P2PIgQY', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-20T16:51:37.317911');
INSERT INTO refresh_token VALUES ('pGUqlkGK2NOL5eZmeUyVhQaPVo4rZcDf6ZE61btE7lU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-20T17:38:47.788171');
INSERT INTO refresh_token VALUES ('81JWkjxLHsLI07P4djasZBzbT5j_JW7t9AIV6ZAm3Us', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-20T19:30:57.560927');
INSERT INTO refresh_token VALUES ('CIVOSJ7uwvcXAM5FYwwqr0gAAxixSNwDkQQEzfzI4Y8', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T14:19:29.880699');
INSERT INTO refresh_token VALUES ('Lbz6tlIhRmo1FKS5ztx-O8KUItcho1qRnjmayHGBhsA', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T14:59:02.710654');
INSERT INTO refresh_token VALUES ('CdcvbK43VxO5OS2Mt7TPu14b03p-rfrfZPI7Yva5uQM', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T15:01:55.002665');
INSERT INTO refresh_token VALUES ('H7pTnkgacLsDo5Q8a9kgXiu40KnpmvzgjUc0kN77dog', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T15:05:12.158396');
INSERT INTO refresh_token VALUES ('HAj8wC6Ms4UbwMUH3rDvYY_rCW4x8lk4_K4UWksxeis', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T15:06:20.191688');
INSERT INTO refresh_token VALUES ('s7ZXKuvgKZCWy21T6_YhJpVsjngTpZVvPpNAzFwBtbM', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T15:08:43.355088');
INSERT INTO refresh_token VALUES ('u2uO0Dju_kZG6kaJ0J63fgolWiXuyWNh18LPXgevoqs', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T15:10:08.699744');
INSERT INTO refresh_token VALUES ('hsDvZnRnfHEhY82IIpyr4Mn4MPW_7T_V1ACdvVL9QyU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T15:19:31.990918');
INSERT INTO refresh_token VALUES ('ZQ57NAJmHjTq396RVieln1LlVWTcgp_-RouGb5mwPuY', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T15:30:19.792729');
INSERT INTO refresh_token VALUES ('7IH2C_Q1DMJhzny5XEHGALPYXSfHr7QMUN85GJ0iUww', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T15:40:35.496937');
INSERT INTO refresh_token VALUES ('0KpOsBI1QfyM9We3Ktlc_qYD0rWVB9_j-qGFmrHkezU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T15:42:06.890967');
INSERT INTO refresh_token VALUES ('G83OwCfysqxesURH6Xzb0iwoQi9FiVhzMsJBJDl8xqw', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T15:45:59.932195');
INSERT INTO refresh_token VALUES ('BnmECcYkJXfm8WPPyCJEHodLGpvZ3jrbJ6zpmrMC-SA', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T15:48:04.470379');
INSERT INTO refresh_token VALUES ('68TR-arb4J1XyY2iBdc6tNOa7L0wsKMwb0fswYb4ekQ', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T15:51:07.819736');
INSERT INTO refresh_token VALUES ('uk9VIVLapgmUU7smYqhA0AZZIg1Su9qHzqpUcRfzIdo', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T15:56:45.051950');
INSERT INTO refresh_token VALUES ('4GBalAGqFiquu2uAYr_TfYPVlwN_De9Recm1oLmMkqY', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T15:57:55.700420');
INSERT INTO refresh_token VALUES ('fiH02SKBhIh4AfwC1AJYFz7puDR36kXa-LgKRfn6gcg', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T15:58:21.867181');
INSERT INTO refresh_token VALUES ('LN6hCK9f2jCLXIOOwi05BNn7E9duhtCKoVxZPi7a2Wo', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T16:01:33.323714');
INSERT INTO refresh_token VALUES ('4GbJTKm93SrHIlhsu11Cx2YrP0bypH4LzP3N-H6nYjM', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T16:02:19.218805');
INSERT INTO refresh_token VALUES ('PRkEWPfgM1lXYkrtHMoYxnV-7w6zppmcGabpKlASXtg', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T16:03:17.757496');
INSERT INTO refresh_token VALUES ('otAo_mtZm9wxo2Odho1DFAiF-Vyx9D0TLAvZbEWYvtU', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T16:05:30.790408');
INSERT INTO refresh_token VALUES ('xaSIcsRjlTusL0frn_qZyOoVBpzgGDs5jOsb-ZR8WYI', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T16:06:32.939167');
INSERT INTO refresh_token VALUES ('_LIejkWsgU4Ys-NjTsxycewxp25XOQZIACJD8TIgMsA', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T16:08:22.432700');
INSERT INTO refresh_token VALUES ('PrQXwiIiPHe5alj01MLT1MqKmWKiyv0bx9emne4wfzk', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T16:13:43.552613');
INSERT INTO refresh_token VALUES ('OMx1ofLw-BttXVu7p3w5Qa6RQWr2F8bBdyydYeDaVnk', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T16:31:54.369000');
INSERT INTO refresh_token VALUES ('fD5blg17_m5RhU3oJABSa8HvwqSZ0-VcgnSlOe0eVbw', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T16:48:37.678180');
INSERT INTO refresh_token VALUES ('ocIyl7E5xDV2vDVFbA6CJyVCA93mlUP5ym4Qn-LWJqE', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T16:49:50.055092');
INSERT INTO refresh_token VALUES ('NuXqmYgPa0DoVJt0R8THZJtDco0QbzO0wVIWkuEbx1w', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T17:00:43.924130');
INSERT INTO refresh_token VALUES ('Mwh5F98r6D7LqA-362sSccL2WCcopsTcbTCGa6rgtqE', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T17:06:00.902546');
INSERT INTO refresh_token VALUES ('SV_ikx0-aR4JC7duca3qW45c1NBJzWlJ_Hdo-irmnv8', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T17:08:35.988760');
INSERT INTO refresh_token VALUES ('RRHuTIn9pKKH1fsrMSbaHhUYZgCll9SH5A-fhjkUuZc', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T17:16:44.444405');
INSERT INTO refresh_token VALUES ('7UWO80uR_Z5zth3zkRDGYuSQlOBax4Hm3Sd00WKqiLY', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T17:19:09.590594');
INSERT INTO refresh_token VALUES ('zDuJnO8NLgsWYP7g7GfU-ZcKSCt5svI9nSM02MgE4-M', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-21T17:36:55.526744');
INSERT INTO refresh_token VALUES ('yMzCArmqPKZXnHHTd7bi7_RXGHURjBpinYKpOfrZPOs', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-21T17:42:28.721280');
INSERT INTO refresh_token VALUES ('bGLypmAHSQOC4lRUyyEJISVujjQnxTyLqvGLsX-lTxo', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-21T17:52:10.728458');
INSERT INTO refresh_token VALUES ('xcYoS6D3A7-oV2XZqLh149K_G1OL1Q78TrZl1LdmvyQ', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-21T17:52:44.114187');
INSERT INTO refresh_token VALUES ('-96l8Q1OI9vOwA1HiyaRHy9pun1uXRAE0Z4XQ70qzLE', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-21T17:53:10.726094');
INSERT INTO refresh_token VALUES ('93wAAXhVXwaWgNhtPsBr89UkzUbzKkp0yDHfpgYiOpY', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T17:56:24.867256');
INSERT INTO refresh_token VALUES ('D4vWITYcM9aV6yzuZ7U99FPHfMQ_4t6scWG8fAwIVNc', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-21T17:57:53.117033');
INSERT INTO refresh_token VALUES ('gJARMCzggkCYHUAJYDZ_pgjh5VtK1mn6Pu6IXMW53T4', 5bad811b-4e15-45ce-86b9-1fac5d36ae74, '2025-08-21T19:10:34.606129');
INSERT INTO refresh_token VALUES ('4EG-0RutVjJTd2tqjppWL5phW5lqPzRoHsuAn_PrDFI', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-21T19:11:06.533346');
INSERT INTO refresh_token VALUES ('34eT5rl7eyfN9FLwFSNzDfJm8pN4JAEYTiww1G_T5YQ', 169448d4-2aa7-45c0-a412-fb2eab2330c5, '2025-08-26T21:18:40.497837');


-- Table: reset_password_token
DROP TABLE IF EXISTS reset_password_token CASCADE;
CREATE TABLE reset_password_token (
    id character varying NOT NULL,
    email character varying NOT NULL,
    created_at timestamp without time zone NOT NULL DEFAULT timezone('utc'::text, now())
);


-- Table: review
DROP TABLE IF EXISTS review CASCADE;
CREATE TABLE review (
    id integer NOT NULL DEFAULT nextval('review_id_seq'::regclass),
    rating integer NOT NULL,
    created_at timestamp without time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at timestamp without time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    quest_id integer NOT NULL,
    text character varying NOT NULL,
    user_id uuid NOT NULL
);


-- Table: review_response
DROP TABLE IF EXISTS review_response CASCADE;
CREATE TABLE review_response (
    id integer NOT NULL DEFAULT nextval('review_response_id_seq'::regclass),
    text character varying NOT NULL,
    created_at timestamp without time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at timestamp without time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    review_id integer NOT NULL,
    user_id uuid NOT NULL
);


-- Table: tool
DROP TABLE IF EXISTS tool CASCADE;
CREATE TABLE tool (
    id integer NOT NULL DEFAULT nextval('tool_id_seq'::regclass),
    name character varying NOT NULL,
    image character varying NOT NULL
);

-- Data for table tool
INSERT INTO tool VALUES (1, 'None', 'none.jpg');
INSERT INTO tool VALUES (2, 'Screen illustration descriptor', 'screen.jpg');
INSERT INTO tool VALUES (3, 'Beeping radar', 'beeping_radar.jpg');
INSERT INTO tool VALUES (4, 'Orbital radar', 'orbital_radar.jpg');
INSERT INTO tool VALUES (5, 'Mile orbital radar', 'mile_orbital.jpg');
INSERT INTO tool VALUES (6, 'Unlim orbital radar', 'unlim_orbital.jpg');
INSERT INTO tool VALUES (7, 'Target compass', 'target_compass.jpg');
INSERT INTO tool VALUES (8, 'Rangefinder', 'rangefinder.jpg');
INSERT INTO tool VALUES (9, 'Rangefinder unlim', 'rangefinder_unlim.jpg');
INSERT INTO tool VALUES (10, 'Echolocation screen', 'echolocation.jpg');
INSERT INTO tool VALUES (11, 'QR scanner', 'qr_scanner.jpg');
INSERT INTO tool VALUES (12, 'Camera tool', 'camera_tool.jpg');
INSERT INTO tool VALUES (13, 'Word locker', 'word_locker.jpg');


-- Table: unlock_request
DROP TABLE IF EXISTS unlock_request CASCADE;
CREATE TABLE unlock_request (
    id integer NOT NULL DEFAULT nextval('unlock_request_id_seq'::regclass),
    email character varying NOT NULL,
    reason character varying NOT NULL,
    unlock_request_status_enum USER-DEFINED NOT NULL,
    message character varying NOT NULL,
    updated_at timestamp without time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    created_at timestamp without time zone NOT NULL DEFAULT timezone('utc'::text, now())
);


-- Table: user
DROP TABLE IF EXISTS user CASCADE;
CREATE TABLE user (
    id uuid NOT NULL,
    username character varying NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    full_name character varying NOT NULL,
    password character varying NOT NULL,
    email character varying NOT NULL,
    profile_id integer NOT NULL,
    role integer NOT NULL,
    is_active boolean NOT NULL,
    is_verified boolean NOT NULL,
    created_at timestamp without time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at timestamp without time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    can_edit_quests boolean NOT NULL DEFAULT false,
    can_lock_users boolean NOT NULL DEFAULT false
);

-- Data for table user
INSERT INTO user VALUES ('postgres');


-- Table: vehicle
DROP TABLE IF EXISTS vehicle CASCADE;
CREATE TABLE vehicle (
    id integer NOT NULL DEFAULT nextval('vehicle_id_seq'::regclass),
    name character varying NOT NULL
);

-- Data for table vehicle
INSERT INTO vehicle VALUES (1, 'Walking');
INSERT INTO vehicle VALUES (2, 'Bicycle');
INSERT INTO vehicle VALUES (3, 'Car');
INSERT INTO vehicle VALUES (4, 'Public Transport');

