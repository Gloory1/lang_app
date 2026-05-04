-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE listenly_app.app_genres (
  id integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  name character varying NOT NULL UNIQUE,
  icon_url text,
  CONSTRAINT app_genres_pkey PRIMARY KEY (id)
);
CREATE TABLE listenly_app.app_languages (
  id integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  code character varying NOT NULL UNIQUE,
  name character varying NOT NULL,
  name_native character varying NOT NULL,
  flag_icon_url text,
  is_for_learning boolean NOT NULL DEFAULT false,
  is_for_display boolean NOT NULL DEFAULT true,
  CONSTRAINT app_languages_pkey PRIMARY KEY (id)
);
CREATE TABLE listenly_app.app_levels (
  id integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  label character varying NOT NULL UNIQUE,
  CONSTRAINT app_levels_pkey PRIMARY KEY (id)
);
CREATE TABLE listenly_app.app_user_settings (
  user_id uuid NOT NULL,
  theme_mode text DEFAULT 'system'::text,
  ui_language_code text DEFAULT 'en-US'::text,
  learning_language_code text DEFAULT 'en-US'::text,
  notifications_enabled boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT app_user_settings_pkey PRIMARY KEY (user_id),
  CONSTRAINT app_user_settings_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE listenly_app.error_action_policies (
  error_type USER-DEFINED NOT NULL,
  should_deactivate boolean NOT NULL DEFAULT false,
  CONSTRAINT error_action_policies_pkey PRIMARY KEY (error_type)
);
CREATE TABLE listenly_app.error_exceptions (
  lesson_id integer NOT NULL,
  lesson_type USER-DEFINED NOT NULL,
  error_type USER-DEFINED NOT NULL,
  CONSTRAINT error_exceptions_pkey PRIMARY KEY (lesson_id, lesson_type, error_type),
  CONSTRAINT error_exceptions_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES listenly_app.lessons(id)
);
CREATE TABLE listenly_app.genres_info_translations (
  id integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  genre_name character varying NOT NULL,
  language_code character varying NOT NULL,
  translated_name character varying NOT NULL,
  CONSTRAINT genres_info_translations_pkey PRIMARY KEY (id),
  CONSTRAINT genres_info_translations_genre_name_fkey FOREIGN KEY (genre_name) REFERENCES listenly_app.app_genres(name),
  CONSTRAINT genres_info_translations_language_code_fkey FOREIGN KEY (language_code) REFERENCES listenly_app.app_languages(code)
);
CREATE TABLE listenly_app.global_dictionary (
  id integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  target_lang_code character varying NOT NULL,
  native_lang_code character varying NOT NULL,
  target_word character varying NOT NULL,
  translated_word character varying NOT NULL,
  CONSTRAINT global_dictionary_pkey PRIMARY KEY (id),
  CONSTRAINT global_dictionary_target_lang_code_fkey FOREIGN KEY (target_lang_code) REFERENCES listenly_app.app_languages(code),
  CONSTRAINT global_dictionary_native_lang_code_fkey FOREIGN KEY (native_lang_code) REFERENCES listenly_app.app_languages(code)
);
CREATE TABLE listenly_app.lessons (
  id integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  lesson_type USER-DEFINED NOT NULL,
  title character varying NOT NULL,
  subtitle text,
  cover_image_url text,
  level_label character varying,
  target_lang_code character varying,
  genre_name character varying,
  scenario_type character varying,
  speaker_one_name character varying,
  speaker_two_name character varying,
  participants_count integer DEFAULT 1,
  audio_file_url text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  CONSTRAINT lessons_pkey PRIMARY KEY (id),
  CONSTRAINT lessons_level_label_fkey FOREIGN KEY (level_label) REFERENCES listenly_app.app_levels(label),
  CONSTRAINT lessons_target_lang_code_fkey FOREIGN KEY (target_lang_code) REFERENCES listenly_app.app_languages(code),
  CONSTRAINT lessons_genre_name_fkey FOREIGN KEY (genre_name) REFERENCES listenly_app.app_genres(name)
);
CREATE TABLE listenly_app.lessons_favorites (
  id integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  user_id uuid NOT NULL,
  lesson_id integer NOT NULL,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  CONSTRAINT lessons_favorites_pkey PRIMARY KEY (id),
  CONSTRAINT lessons_favorites_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT lessons_favorites_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES listenly_app.lessons(id)
);
CREATE TABLE listenly_app.lessons_info_translations (
  id integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  lesson_id integer NOT NULL,
  language_code character varying NOT NULL,
  translated_title character varying NOT NULL,
  translated_subtitle text,
  CONSTRAINT lessons_info_translations_pkey PRIMARY KEY (id),
  CONSTRAINT lessons_info_translations_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES listenly_app.lessons(id),
  CONSTRAINT lessons_info_translations_language_code_fkey FOREIGN KEY (language_code) REFERENCES listenly_app.app_languages(code)
);
CREATE TABLE listenly_app.lessons_progress (
  id integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  user_id uuid NOT NULL,
  lesson_id integer NOT NULL,
  position_ms integer DEFAULT 0,
  is_completed boolean DEFAULT false,
  completed_at timestamp with time zone,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  total_duration_ms integer DEFAULT 0,
  CONSTRAINT lessons_progress_pkey PRIMARY KEY (id),
  CONSTRAINT lessons_progress_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT lessons_progress_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES listenly_app.lessons(id)
);
CREATE TABLE listenly_app.lessons_srt_subtitles (
  id integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  lesson_id integer NOT NULL,
  language_code character varying NOT NULL,
  srt_file_url text NOT NULL,
  CONSTRAINT lessons_srt_subtitles_pkey PRIMARY KEY (id),
  CONSTRAINT lessons_srt_subtitles_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES listenly_app.lessons(id),
  CONSTRAINT lessons_srt_subtitles_language_code_fkey FOREIGN KEY (language_code) REFERENCES listenly_app.app_languages(code)
);
CREATE TABLE listenly_app.lessons_vocabulary (
  id integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  lesson_id integer NOT NULL,
  word character varying NOT NULL,
  CONSTRAINT lessons_vocabulary_pkey PRIMARY KEY (id),
  CONSTRAINT lessons_vocabulary_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES listenly_app.lessons(id)
);
CREATE TABLE listenly_app.media_error_logs (
  lesson_id integer NOT NULL,
  lesson_type USER-DEFINED NOT NULL,
  error_type USER-DEFINED NOT NULL,
  error_details text,
  created_at timestamp with time zone DEFAULT now(),
  resolved_at timestamp with time zone,
  id integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  CONSTRAINT media_error_logs_pkey PRIMARY KEY (id),
  CONSTRAINT media_error_logs_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES listenly_app.lessons(id)
);
