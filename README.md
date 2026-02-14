# Simple Todo List App
> **Note**: This is a simple todo list app for fullstack showcase
> **NOTE**: Supabase project closed

## Instructions
1. ```flutter clean``` - clean pubsec.yaml
1. ```flutter pub get``` - get all dependecies
2. ```flutter run --debug``` - run in VS Code with emulator
3. ```flutter build apk --release``` - build apk
> .env file is saved locally ask developer for URL and KEY

## General

### Tech Stack
- Flutter - Dart
- Edge Functions - Supabase + Typescript
- PostgreSQL
- Supabase CLI - Local Dev
> Used supabase functions deploy create_user_profile --project-ref project_id to deploy edge functions

### Code Snippet
> Shows basic profiles table
```sql
-- Profiles Table
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    profile_image_url TEXT,
    ultimate_goal TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Security:

- Row Level Security
- Input validation
- Encrypted storage
- Secure sessions

### Support & Resources

- [Supabase Edge Functions Docs](https://supabase.com/docs/guides/functions)
- [Deno Runtime Docs](https://deno.land/manual)
- [Supabase CLI Reference](https://supabase.com/docs/reference/cli)

### Why Edge Functions Are More Secure Over Direct Queries from Flutter

<ol type="I">
  <li>Hidden Business Logic: Your validation rules and business logic stay on the server</li>
  <li>Additional Security Layer: You can add extra auth checks, rate limiting, and validation</li>
  <li>Protected Database Access: Database credentials never exposed to the client</li>
  <li>Server-Side Validation: Can't be bypassed by malicious clients</li>
  <li>Audit Logging: Centralized logging of all operations</li>
  <li>Fine-grained Control: Can implement complex permissions beyond RLS</li>
</ol>

## Extra

### Emulator view
> Screen-shot with snipping tool

<img width="466" height="933" alt="image" src="https://github.com/user-attachments/assets/4b893c53-8c95-44d4-b2d3-1bda69bd96c7" />

