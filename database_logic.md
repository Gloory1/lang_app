### Final Database Design for Language Learning Application (Supabase / PostgreSQL)

This design relies on independent tables for each type of content (stories, podcasts, conversations).

**Note:** Synchronization and translation tables were eliminated due to the reliance on audio files in (MKA) format, which contain the embedded texts within them. 
Independent translation tables were adopted to facilitate the management of the application interface in multiple languages, and independent favorite tables, in addition to smart "Progress Tracking" tables.

---

#### 1. Reference Tables

**Languages Table (`languages`)**
* **`id`** (PK): UUID
* **`code`**: String (e.g., 'en', 'es', 'ar')
* **`name`**: String (e.g., 'English', 'Arabic')
* **`name_native`**: String (e.g., 'English', 'العربية')
* **`flag_icon_url`**: String (Optional - URL for language icon or flag)

**Levels Table (`levels`)**
* **`id`** (PK): UUID
* **`label`**: String (e.g., 'beginner', 'Intermediate', 'Advanced')

**Genres Table (`genres`)**
Used to standardize categories (fiction, historical, technology, business) across all content types.
* **`id`** (PK): UUID
* **`name`**: String (e.g., 'Technology', 'Fantasy', 'Business')
* **`icon_url`**: String (Optional - icon URL)

---

#### 2. Core Content Tables (Content Tables)

These tables contain the data in the primary (default) language.

**Stories Table (`stories_lessons`)**
* **`id`** (PK): UUID
* **`title`**: String
* **`description`**: Text
* **`cover_image_url`**: String
* **`level_id`** (FK): UUID
* **`target_lang_id`** (FK): UUID
* **`genre_id`** (FK): UUID
* **`audio_mka_url`**: String
* **`author_name`**: String
* **`created_at`**: Timestamp

**Podcast Table (`podcast_lessons`)**
* **`id`** (PK): UUID
* **`title`**: String
* **`description`**: Text
* **`cover_image_url`**: String
* **`level_id`** (FK): UUID
* **`target_lang_id`** (FK): UUID
* **`genre_id`** (FK): UUID
* **`audio_mka_url`**: String
* **`host_name`**: String
* **`created_at`**: Timestamp
  
---

#### 3. Translations, Favorites, and Progress Tables (Translations, Favorites & Progress)

**3.1 Translations Tables**
A dedicated translation table was created for each entity to avoid complexity and speed up queries.

**Genre Translations Table (`genre_translations`)**
* **`id`** (PK): UUID
* **`genre_id`** (FK): UUID
* **`language_id`** (FK): UUID
* **`translated_name`**: String

**Story Translations Table (`story_translations`)**
* **`id`** (PK): UUID
* **`story_id`** (FK): UUID
* **`language_id`** (FK): UUID
* **`translated_title`**: String
* **`translated_description`**: Text

**Podcast Translations Table (`podcast_translations`)**
* **`id`** (PK): UUID
* **`podcast_id`** (FK): UUID
* **`language_id`** (FK): UUID
* **`translated_title`**: String
* **`translated_description`**: Text

**Conversation Translations Table (`conversation_translations`)**
* **`id`** (PK): UUID
* **`conversation_id`** (FK): UUID
* **`language_id`** (FK): UUID
* **`translated_title`**: String
* **`translated_description`**: Text

**3.2 Favorites Tables**
Favorites were separated so that each content type has its own table.

**Stories Favorites Table (`stories_lessons_favorites`)**
* **`id`** (PK): UUID
* **`user_id`** (FK): UUID
* **`story_id`** (FK): UUID
* **`created_at`**: Timestamp

**Podcast Favorites Table (`podcast_lessons_favorites`)**
* **`id`** (PK): UUID
* **`user_id`** (FK): UUID
* **`podcast_id`** (FK): UUID
* **`created_at`**: Timestamp

**Conversations Favorites Table (`conversations_lessons_favorites`)**
* **`id`** (PK): UUID
* **`user_id`** (FK): UUID
* **`conversation_id`** (FK): UUID
* **`created_at`**: Timestamp

**3.3 Progress Tracking Tables**
Smart tracking that allows resuming playback and knowing completed lessons. If there is no record, the lesson is "not started".

**Stories Progress Table (`stories_lessons_progress`)**
* **`id`** (PK): UUID
* **`user_id`**: UUID (Linked to Supabase Auth)
* **`story_id`** (FK): UUID
* **`position_ms`**: Integer (Stop position in milliseconds)
* **`is_completed`**: Boolean (Did they finish listening to the end?)
* **`updated_at`**: Timestamp (To sort "continue listening")

**Podcast Progress Table (`podcast_lessons_progress`)**
* **`id`** (PK): UUID
* **`user_id`**: UUID (Linked to Supabase Auth)
* **`podcast_id`** (FK): UUID
* **`position_ms`**: Integer (Stop position in milliseconds)
* **`is_completed`**: Boolean (Did they finish listening to the end?)
* **`updated_at`**: Timestamp (To sort "continue listening")

**Conversations Progress Table (`conversations_lessons_progress`)**
* **`id`** (PK): UUID
* **`user_id`**: UUID (Linked to Supabase Auth)
* **`conversation_id`** (FK): UUID
* **`position_ms`**: Integer (Stop position in milliseconds)
* **`is_completed`**: Boolean (Did they finish listening to the end?)
* **`updated_at`**: Timestamp (To sort "continue listening")
