-- Create Languages Table
CREATE TABLE languages (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  code VARCHAR(5) NOT NULL UNIQUE,
  name VARCHAR(50) NOT NULL,
  name_native VARCHAR(50) NOT NULL,
  flag_icon_url TEXT 
);

-- Create Levels Table
CREATE TABLE levels (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  label VARCHAR(50) NOT NULL UNIQUE
);

-- Create Genres Table
CREATE TABLE genres (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  icon_url TEXT
);

-- Create Stories Table
CREATE TABLE stories_lessons (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  cover_image_url TEXT, 
  level_id UUID REFERENCES levels(id) ON DELETE SET NULL,
  target_lang_id UUID REFERENCES languages(id) ON DELETE CASCADE,
  genre_id UUID REFERENCES genres(id) ON DELETE SET NULL,
  audio_mka_url TEXT NOT NULL,
  author_name VARCHAR(255),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create Podcasts Table
CREATE TABLE podcast_lessons (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  cover_image_url TEXT, 
  level_id UUID REFERENCES levels(id) ON DELETE SET NULL,
  target_lang_id UUID REFERENCES languages(id) ON DELETE CASCADE,
  genre_id UUID REFERENCES genres(id) ON DELETE SET NULL,
  audio_mka_url TEXT NOT NULL,
  host_name VARCHAR(255) NOT NULL,
  guest_name VARCHAR(255),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create Conversations Table
CREATE TABLE conversations_lessons (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  cover_image_url TEXT, 
  level_id UUID REFERENCES levels(id) ON DELETE SET NULL,
  target_lang_id UUID REFERENCES languages(id) ON DELETE CASCADE,
  genre_id UUID REFERENCES genres(id) ON DELETE SET NULL,
  scenario_type VARCHAR(255),
  speaker_one_name VARCHAR(100) NOT NULL,
  speaker_two_name VARCHAR(100) NOT NULL,
  participants_count INTEGER DEFAULT 2,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- ==========================================
-- Translations Tables
-- ==========================================

-- Create Genre Info Translations Table
CREATE TABLE genres_info_translations (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  genre_id UUID NOT NULL REFERENCES genres(id) ON DELETE CASCADE,
  language_id UUID NOT NULL REFERENCES languages(id) ON DELETE CASCADE,
  translated_name VARCHAR(100) NOT NULL,
  UNIQUE(genre_id, language_id)
);

-- Create Story Lessons Info Translations Table
CREATE TABLE stories_lessons_info_translations (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  story_id UUID NOT NULL REFERENCES stories_lessons(id) ON DELETE CASCADE,
  language_id UUID NOT NULL REFERENCES languages(id) ON DELETE CASCADE,
  translated_title VARCHAR(255) NOT NULL,
  translated_description TEXT,
  UNIQUE(story_id, language_id)
);

-- Create Podcast Lessons Info Translations Table
CREATE TABLE podcast_lessons_info_translations (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  podcast_id UUID NOT NULL REFERENCES podcast_lessons(id) ON DELETE CASCADE,
  language_id UUID NOT NULL REFERENCES languages(id) ON DELETE CASCADE,
  translated_title VARCHAR(255) NOT NULL,
  translated_description TEXT,
  UNIQUE(podcast_id, language_id)
);

-- Create Conversation Lessons Info Translations Table
CREATE TABLE conversations_lessons_info_translations (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  conversation_id UUID NOT NULL REFERENCES conversations_lessons(id) ON DELETE CASCADE,
  language_id UUID NOT NULL REFERENCES languages(id) ON DELETE CASCADE,
  translated_title VARCHAR(255) NOT NULL,
  translated_description TEXT,
  UNIQUE(conversation_id, language_id)
);

-- ==========================================
-- Favorites Tables
-- ==========================================

-- Create Favorites Table for Stories
CREATE TABLE stories_lessons_favorites (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE, 
  story_id UUID NOT NULL REFERENCES stories_lessons(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  UNIQUE(user_id, story_id)
);

-- Create Favorites Table for Podcasts
CREATE TABLE podcast_lessons_favorites (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE, 
  podcast_id UUID NOT NULL REFERENCES podcast_lessons(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  UNIQUE(user_id, podcast_id)
);

-- Create Favorites Table for Conversations
CREATE TABLE conversations_lessons_favorites (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE, 
  conversation_id UUID NOT NULL REFERENCES conversations_lessons(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  UNIQUE(user_id, conversation_id)
);

-- ==========================================
-- Progress Tracking Tables
-- ==========================================

-- Create Progress Table for Stories
CREATE TABLE stories_lessons_progress (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  story_id UUID NOT NULL REFERENCES stories_lessons(id) ON DELETE CASCADE,
  position_ms INTEGER DEFAULT 0,
  is_completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  UNIQUE(user_id, story_id)
);

-- Create Progress Table for Podcasts
CREATE TABLE podcast_lessons_progress (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  podcast_id UUID NOT NULL REFERENCES podcast_lessons(id) ON DELETE CASCADE,
  position_ms INTEGER DEFAULT 0,
  is_completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  UNIQUE(user_id, podcast_id)
);

-- Create Progress Table for Conversations
CREATE TABLE conversations_lessons_progress (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  conversation_id UUID NOT NULL REFERENCES conversations_lessons(id) ON DELETE CASCADE,
  position_ms INTEGER DEFAULT 0,
  is_completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  UNIQUE(user_id, conversation_id)
);

-- ==========================================
-- Vocabulary & Dictionary Tables
-- ==========================================

-- Create Central Global Dictionary Table
CREATE TABLE global_dictionary (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  target_lang_id UUID NOT NULL REFERENCES languages(id) ON DELETE CASCADE,
  native_lang_id UUID NOT NULL REFERENCES languages(id) ON DELETE CASCADE,
  target_word VARCHAR(255) NOT NULL,
  translated_word VARCHAR(255) NOT NULL,
  
  -- Prevent duplicate translations for the same word between two specific languages
  UNIQUE(target_lang_id, native_lang_id, target_word)
);

-- Create Vocabulary Table for Stories
CREATE TABLE stories_lessons_vocabulary (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  story_id UUID NOT NULL REFERENCES stories_lessons(id) ON DELETE CASCADE,
  word VARCHAR(255) NOT NULL,
  UNIQUE(story_id, word)
);

-- Create Vocabulary Table for Podcasts
CREATE TABLE podcast_lessons_vocabulary (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  podcast_id UUID NOT NULL REFERENCES podcast_lessons(id) ON DELETE CASCADE,
  word VARCHAR(255) NOT NULL,
  UNIQUE(podcast_id, word)
);

-- Create Vocabulary Table for Conversations
CREATE TABLE conversations_lessons_vocabulary (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  conversation_id UUID NOT NULL REFERENCES conversations_lessons(id) ON DELETE CASCADE,
  word VARCHAR(255) NOT NULL,
  UNIQUE(conversation_id, word)
);









