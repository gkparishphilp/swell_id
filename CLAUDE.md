# CLAUDE.md - SwellId Engine

## Purpose

SwellId is a Rails engine providing user authentication and identity management built on Devise. It supplies the core User model concerns, geographic address models with hash-based deduplication, a polymorphic identifier system, role-based authorization, and optional Elasticsearch integration.

**Version:** 3.0.3

## Key Models

All models live in the host application. SwellId provides concerns that get mixed in.

### User

- **Concern**: `SwellId::Concerns::UserConcern`
- **Devise modules**: `database_authenticatable`, `registerable`, `recoverable`, `rememberable`, `trackable`
- **Authentication key**: `:login` (virtual attribute supporting email or username login)
- **FriendlyId**: Generates slug from username, full_name, or email prefix
- **Tags**: `acts_as_taggable_array_on :tags`

**Enums** (defined in host app):

| Enum | Values |
|------|--------|
| `status` | `trash: -50`, `revoked: -20`, `active: 1` |
| `role` | `member: 1`, `contributor: 20`, `support: 25`, `admin: 30` |
| `availability` | `just_me: 0`, `anyone: 1`, `logged_in_users: 2`, `friends: 3` |
| `subscriber_reputation_type` | `subscriber_reputation_calculated: 0`, `subscriber_reputation_whitelist: 1`, `subscriber_reputation_blacklist: -1` |

**Key methods**: `full_name`, `full_name=`, `email=` (downcases), `to_s`, `registered?`, `avatar_tag`, `tags_csv`/`tags_csv=`, `find_for_database_authentication`

### GeoAddress

- **Concern**: `SwellId::Concerns::AddressConcern`
- **Enums**: `status`: `active: 1`, `trash: -50`
- **Associations**: `belongs_to :geo_state` (optional), `belongs_to :geo_country`, `belongs_to :user` (optional)
- **Deduplication**: Uses `hash_code` computed from street, street2, zip, city, state_abbrev, country_abbrev. `before_save :set_hash_code`.
- **Validations**: Requires first_name, last_name, street, city, zip
- **Key methods**: `calculate_hash_code`, `canonical_find`, `canonical_find_or_self`, `equals`, `find_duplicates`, `state_name`, `state_abbrev`, `to_html`

### UserAddress

- **Concern**: `SwellId::Concerns::UserAddressConcern`
- **Associations**: `belongs_to :geo_address`, `belongs_to :user`
- **Delegates** all address fields to `geo_address`
- **Canonical deduplication**: `canonical_find`, `canonical_geo_address!` (before_save)
- **`accepts_nested_attributes_for :geo_address`**

### GeoCountry / GeoState

- `GeoCountry` `has_many :geo_states`. Columns: name, abbrev
- `GeoState` `belongs_to :geo_country`. Columns: name, abbrev, country

### Identifier

- **Concern**: `SwellId::Concerns::IdentifierConcern`
- **Associations**: `belongs_to :parent_obj, polymorphic: true`
- **Validations**: Requires `identifier`, `provider`, `label`; unique on `[identifier, provider, label]`

### ClientApp

- OAuth/JWT token client configuration
- `enum status`: `trash: -50`, `revoked: -20`, `active: 1`
- Methods: `encode(payload, exp)`, `decode(token)`, `generate_client_id`

## Additional Concerns

- **MultiIdentifierConcern** - Adds `has_many :identifiers` and `find_by_identifier` to any model
- **PolymorphicIdentifiers** - Enhanced polymorphic_id support with format `{model_class_underscored}/{id}`

## Controllers

### Engine-Provided

- **`UserAdminController`** - Admin CRUD for users
- **`IdentifierAdminController`** - Admin CRUD for identifiers

### Controller Concerns

- **`ApplicationControllerConcern`** - Provides `client_ip` (Cloudflare-aware), `client_ip_country`, `register_then`
- **`PermissionConcern`** - Role-based authorization via `authorize`/`authorized?`. Dynamically instantiates role classes based on `current_user.role`.

## Authorization / Roles

Role hierarchy (in `app/roles/swell_id/`):

- **`SwellId::Role`** - Abstract base
- **`AdminRole`** - Allows everything
- **`MemberRole`** - Blocks admin controllers
- **`ContributorRole`** - Blocks admin controllers
- **`GuestRole`** - Blocks everything

Selection: `"#{current_user.role}_role".camelcase.constantize`

## Configuration

```ruby
SwellId.configure do |config|
  config.default_user_status = 'pending'  # default
end
```

## Devise Configuration

Key settings from install template:
- `authentication_keys: [:login]` - login via email or username
- `case_insensitive_keys: [:email, :username]`
- `password_length: 4..128`
- `remember_for: 2.weeks`

## Database Schema

Creates tables: `users`, `geo_addresses`, `geo_countries`, `geo_states`, `identifiers`, `oauth_credentials`, `friendly_id_slugs`

Enables PostgreSQL extensions: `hstore`, `uuid-ossp`

## Dependencies

- `rails` >= 5.2.0
- `devise` - Authentication
- `friendly_id` >= 5.1.0 - URL slugs
- `acts-as-taggable-array-on` - PostgreSQL array-based tagging

## Key Patterns

1. **Concerns over inheritance** - All model logic lives in concerns mixed into host app models
2. **Canonical address deduplication** - Hash-code based deduplication for GeoAddress and UserAddress
3. **Login via email or username** - Virtual `login` attribute with `find_for_database_authentication`
4. **Role-based authorization** - Dynamic role class instantiation from user role enum
