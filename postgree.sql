
\-- Create Languages Table  
CREATE TABLE languages (  
  id UUID DEFAULT uuid\_generate\_v4() PRIMARY KEY,  
  code VARCHAR(5) NOT NULL UNIQUE,  
  name VARCHAR(50) NOT NULL,  
  name\_native VARCHAR(50) NOT NULL,  
  flag\_icon\_url TEXT   
);

\-- Create Levels Table  
CREATE TABLE levels (  
  id UUID DEFAULT uuid\_generate\_v4() PRIMARY KEY,  
  label VARCHAR(50) NOT NULL UNIQUE  
);

\-- Create Genres Table  
CREATE TABLE genres (  
  id UUID DEFAULT uuid\_generate\_v4() PRIMARY KEY,  
  name VARCHAR(100) NOT NULL UNIQUE,  
  icon\_url TEXT  
);

\-- Create Stories Table  
CREATE TABLE stories\_lessons (  
  id UUID DEFAULT uuid\_generate\_v4() PRIMARY KEY,  
  title VARCHAR(255) NOT NULL,  
  description TEXT,  
  cover\_image\_url TEXT,   
  level\_id UUID REFERENCES levels(id) ON DELETE SET NULL,  
  target\_lang\_id UUID REFERENCES languages(id) ON DELETE CASCADE,  
  genre\_id UUID REFERENCES genres(id) ON DELETE SET NULL,  
  audio\_mka\_url TEXT NOT NULL,  
  author\_name VARCHAR(255),  
  created\_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())  
);

\-- Create Podcasts Table  
CREATE TABLE podcast\_lessons (  
  id UUID DEFAULT uuid\_generate\_v4() PRIMARY KEY,  
  title VARCHAR(255) NOT NULL,  
  description TEXT,  
  cover\_image\_url TEXT,   
  level\_id UUID REFERENCES levels(id) ON DELETE SET NULL,  
  target\_lang\_id UUID REFERENCES languages(id) ON DELETE CASCADE,  
  genre\_id UUID REFERENCES genres(id) ON DELETE SET NULL,  
  audio\_mka\_url TEXT NOT NULL,  
  host\_name VARCHAR(255) NOT NULL,  
  guest\_name VARCHAR(255),  
  created\_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())  
);

\-- Create Conversations Table  
CREATE TABLE conversations\_lessons (  
  id UUID DEFAULT uuid\_generate\_v4() PRIMARY KEY,  
  title VARCHAR(255) NOT NULL,  
  description TEXT,  
  cover\_image\_url TEXT,   
  level\_id UUID REFERENCES levels(id) ON DELETE SET NULL,  
  target\_lang\_id UUID REFERENCES languages(id) ON DELETE CASCADE,  
  genre\_id UUID REFERENCES genres(id) ON DELETE SET NULL,  
  scenario\_type VARCHAR(255),  
  speaker\_one\_name VARCHAR(100) NOT NULL,  
  speaker\_two\_name VARCHAR(100) NOT NULL,  
  participants\_count INTEGER DEFAULT 2,  
  created\_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())  
);

\-- \==========================================  
\-- Translations Tables  
\-- \==========================================

\-- Create Genre Info Translations Table  
CREATE TABLE genres\_info\_translations (  
  id UUID DEFAULT uuid\_generate\_v4() PRIMARY KEY,  
  genre\_id UUID NOT NULL REFERENCES genres(id) ON DELETE CASCADE,  
  language\_id UUID NOT NULL REFERENCES languages(id) ON DELETE CASCADE,  
  translated\_name VARCHAR(100) NOT NULL,  
  UNIQUE(genre\_id, language\_id)  
);

\-- Create Story Lessons Info Translations Table  
CREATE TABLE stories\_lessons\_info\_translations (  
  id UUID DEFAULT uuid\_generate\_v4() PRIMARY KEY,  
  story\_id UUID NOT NULL REFERENCES stories\_lessons(id) ON DELETE CASCADE,  
  language\_id UUID NOT NULL REFERENCES languages(id) ON DELETE CASCADE,  
  translated\_title VARCHAR(255) NOT NULL,  
  translated\_description TEXT,  
  UNIQUE(story\_id, language\_id)  
);

\-- Create Podcast Lessons Info Translations Table  
CREATE TABLE podcast\_lessons\_info\_translations (  
  id UUID DEFAULT uuid\_generate\_v4() PRIMARY KEY,  
  podcast\_id UUID NOT NULL REFERENCES podcast\_lessons(id) ON DELETE CASCADE,  
  language\_id UUID NOT NULL REFERENCES languages(id) ON DELETE CASCADE,  
  translated\_title VARCHAR(255) NOT NULL,  
  translated\_description TEXT,  
  UNIQUE(podcast\_id, language\_id)  
);

\-- Create Conversation Lessons Info Translations Table  
CREATE TABLE conversations\_lessons\_info\_translations (  
  id UUID DEFAULT uuid\_generate\_v4() PRIMARY KEY,  
  conversation\_id UUID NOT NULL REFERENCES conversations\_lessons(id) ON DELETE CASCADE,  
  language\_id UUID NOT NULL REFERENCES languages(id) ON DELETE CASCADE,  
  translated\_title VARCHAR(255) NOT NULL,  
  translated\_description TEXT,  
  UNIQUE(conversation\_id, language\_id)  
);

\-- \==========================================  
\-- Favorites Tables  
\-- \==========================================

\-- Create Favorites Table for Stories  
CREATE TABLE stories\_lessons\_favorites (  
  id UUID DEFAULT uuid\_generate\_v4() PRIMARY KEY,  
  user\_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,   
  story\_id UUID NOT NULL REFERENCES stories\_lessons(id) ON DELETE CASCADE,  
  created\_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),  
  UNIQUE(user\_id, story\_id)  
);

\-- Create Favorites Table for Podcasts  
CREATE TABLE podcast\_lessons\_favorites (  
  id UUID DEFAULT uuid\_generate\_v4() PRIMARY KEY,  
  user\_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,   
  podcast\_id UUID NOT NULL REFERENCES podcast\_lessons(id) ON DELETE CASCADE,  
  created\_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),  
  UNIQUE(user\_id, podcast\_id)  
);

\-- Create Favorites Table for Conversations  
CREATE TABLE conversations\_lessons\_favorites (  
  id UUID DEFAULT uuid\_generate\_v4() PRIMARY KEY,  
  user\_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,   
  conversation\_id UUID NOT NULL REFERENCES conversations\_lessons(id) ON DELETE CASCADE,  
  created\_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),  
  UNIQUE(user\_id, conversation\_id)  
);

\-- \==========================================  
\-- Progress Tracking Tables  
\-- \==========================================

\-- Create Progress Table for Stories  
CREATE TABLE stories\_lessons\_progress (  
  id UUID DEFAULT uuid\_generate\_v4() PRIMARY KEY,  
  user\_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,  
  story\_id UUID NOT NULL REFERENCES stories\_lessons(id) ON DELETE CASCADE,  
  position\_ms INTEGER DEFAULT 0,  
  is\_completed BOOLEAN DEFAULT FALSE,  
  completed\_at TIMESTAMP WITH TIME ZONE,  
  updated\_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),  
  UNIQUE(user\_id, story\_id)  
);

\-- Create Progress Table for Podcasts  
CREATE TABLE podcast\_lessons\_progress (  
  id UUID DEFAULT uuid\_generate\_v4() PRIMARY KEY,  
  user\_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,  
  podcast\_id UUID NOT NULL REFERENCES podcast\_lessons(id) ON DELETE CASCADE,  
  position\_ms INTEGER DEFAULT 0,  
  is\_completed BOOLEAN DEFAULT FALSE,  
  completed\_at TIMESTAMP WITH TIME ZONE,  
  updated\_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),  
  UNIQUE(user\_id, podcast\_id)  
);

\-- Create Progress Table for Conversations  
CREATE TABLE conversations\_lessons\_progress (  
  id UUID DEFAULT uuid\_generate\_v4() PRIMARY KEY,  
  user\_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,  
  conversation\_id UUID NOT NULL REFERENCES conversations\_lessons(id) ON DELETE CASCADE,  
  position\_ms INTEGER DEFAULT 0,  
  is\_completed BOOLEAN DEFAULT FALSE,  
  completed\_at TIMESTAMP WITH TIME ZONE,  
  updated\_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),  
  UNIQUE(user\_id, conversation\_id)  
);

\-- \==========================================  
\-- Vocabulary & Dictionary Tables  
\-- \==========================================

\-- Create Central Global Dictionary Table  
CREATE TABLE global\_dictionary (  
  id UUID DEFAULT uuid\_generate\_v4() PRIMARY KEY,  
  target\_lang\_id UUID NOT NULL REFERENCES languages(id) ON DELETE CASCADE,  
  native\_lang\_id UUID NOT NULL REFERENCES languages(id) ON DELETE CASCADE,  
  target\_word VARCHAR(255) NOT NULL,  
  translated\_word VARCHAR(255) NOT NULL,  
    
  \-- Prevent duplicate translations for the same word between two specific languages  
  UNIQUE(target\_lang\_id, native\_lang\_id, target\_word)  
);

\-- Create Vocabulary Table for Stories  
CREATE TABLE stories\_lessons\_vocabulary (  
  id UUID DEFAULT uuid\_generate\_v4() PRIMARY KEY,  
  story\_id UUID NOT NULL REFERENCES stories\_lessons(id) ON DELETE CASCADE,  
  word VARCHAR(255) NOT NULL,  
  UNIQUE(story\_id, word)  
);

\-- Create Vocabulary Table for Podcasts  
CREATE TABLE podcast\_lessons\_vocabulary (  
  id UUID DEFAULT uuid\_generate\_v4() PRIMARY KEY,  
  podcast\_id UUID NOT NULL REFERENCES podcast\_lessons(id) ON DELETE CASCADE,  
  word VARCHAR(255) NOT NULL,  
  UNIQUE(podcast\_id, word)  
);

\-- Create Vocabulary Table for Conversations  
CREATE TABLE conversations\_lessons\_vocabulary (  
  id UUID DEFAULT uuid\_generate\_v4() PRIMARY KEY,  
  conversation\_id UUID NOT NULL REFERENCES conversations\_lessons(id) ON DELETE CASCADE,  
  word VARCHAR(255) NOT NULL,  
  UNIQUE(conversation\_id, word)  
);
