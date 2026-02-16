# SwellId

A Rails engine for user authentication and identity management, built on Devise. Provides core User model concerns, geographic address handling with hash-based deduplication, a polymorphic identifier system, and role-based authorization.

See [CLAUDE.md](CLAUDE.md) for detailed architecture documentation.

## Features

- Devise-based authentication with email-or-username login
- FriendlyId URL slugs for users
- PostgreSQL array-based tagging via acts-as-taggable-array-on
- Geographic models: GeoAddress (with hash-code deduplication), GeoCountry, GeoState, UserAddress
- Polymorphic Identifier model for external provider IDs
- Role-based authorization (Admin, Member, Contributor, Guest)
- Optional Elasticsearch integration
- Cloudflare-aware IP detection

## Models

| Model | Purpose |
|-------|---------|
| `User` | Authentication, identity, profile (via UserConcern) |
| `GeoAddress` | Physical addresses with hash-based deduplication |
| `UserAddress` | User-address join with canonical lookups |
| `GeoCountry` / `GeoState` | Geographic reference data |
| `Identifier` | External provider identifiers (polymorphic) |
| `ClientApp` | OAuth/JWT token client configuration |

## Configuration

```ruby
SwellId.configure do |config|
  config.default_user_status = 'pending'
end
```

## Dependencies

- `rails` >= 5.2.0
- `devise` - Authentication
- `friendly_id` >= 5.1.0 - URL slugs
- `acts-as-taggable-array-on` - PostgreSQL array-based tagging

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
