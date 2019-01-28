# frozen_string_literal: true

require 'telegram/bot'
require_relative 'wordplay_db'

# Bot fot getting random wordplay from Database
class Bot
  def initialize
    @token = '671502180:AAGTzsMZ3nzk_ZTPx0UqlG2m48JendDrGis'
    @bot = Telegram::Bot::Client.new(@token)
    @db = Database.new
  end

  def wordplay
    @db.wordplays_from_page('https://weirdblog.wordpress.com/2009/07/29/humorous-word-play-to-start-your-day')
    @db.random_wordplay
  end

  def user_message(text)
    @bot.api.send_message(chat_id: message.chat.id, text: text)
  end

  def reply(message)
    case message.text
    when '/start'
      'Sup?'
    when 'Hey bot!'
      'Hey bro!'
    when '/wordplay'
      "Here is your random wordplay:\n#{wordplay}"
    else
      'Huh?'
    end
  end

  def run
    @bot.listen do |message|
      @bot.api.send_message(chat_id: message.chat.id, text: reply(message))
    end
  end
end

tg = Bot.new

tg.run
