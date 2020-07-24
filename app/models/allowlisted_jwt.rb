# frozen_string_literal: true

class AllowlistedJwt < ApplicationRecord
  extend ActiveSupport::Concern

  # @see Warden::JWTAuth::Interfaces::RevocationStrategy#jwt_revoked?
  def self.jwt_revoked?(payload, user)
    !user.allowlisted_jwts.exists?(payload.slice('jti', 'aud'))
  end

  # @see Warden::JWTAuth::Interfaces::RevocationStrategy#revoke_jwt
  def self.revoke_jwt(payload, user)
    jwt = user.allowlisted_jwts.find_by(payload.slice('jti', 'aud'))
    jwt&.destroy!
  end
end
