# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable,  and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable, :trackable,
         :jwt_authenticatable, jwt_revocation_strategy: AllowlistedJwt

  has_many :notifications, dependent: :destroy

  def allowlisted_jwts
    AllowlistedJwt
  end

  def on_jwt_dispatch(_token, payload)
    allowlisted_jwts.create!(
      user_id: id,
      jti: payload['jti'],
      aud: payload['aud'],
      exp: Time.zone.at(payload['exp'].to_i)
    )
  end
end
