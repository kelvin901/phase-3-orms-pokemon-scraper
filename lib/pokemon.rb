require 'sqlite3'
require_relative 'scraper'
DB = {:conn => SQLite3::Database.new("db/pokemon.db")}

class Pokemon
  attr_accessor :id, :name, :type, :hp

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS pokemon (
        id INTEGER PRIMARY KEY,
        name TEXT,
        type TEXT,
        hp INTEGER
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS pokemon"
    DB[:conn].execute(sql)
  end

  def save
    sql = "INSERT INTO pokemon (name, type, hp) VALUES (?, ?, ?)"
    DB[:conn].execute(sql, self.name, self.type, self.hp)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM pokemon")[0][0]
  end

  def self.create_from_scraper
    scraper = Scraper.new
    scraper.scrape.each do |pokemon_data|
      pokemon = Pokemon.new
      pokemon.name = pokemon_data[:name]
      pokemon.type = pokemon_data[:type]
      pokemon.hp = pokemon_data[:hp]
      pokemon.save
    end
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM pokemon WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    build_pokemon(result)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM pokemon WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    build_pokemon(result)
  end

  private

  def self.build_pokemon(result)
    return nil if result.nil?

    pokemon = Pokemon.new
    pokemon.id = result[0]
    pokemon.name = result[1]
    pokemon.type = result[2]
    pokemon.hp = result[3]
    pokemon
  end
end
# Create the pokemon table
Pokemon.create_table

# Populate the database with Pokémon data from the scraper
Pokemon.create_from_scraper

# Find a Pokémon by its ID
pikachu = Pokemon.find_by_id(1)
puts pikachu.name # Output: Pikachu

# Find a Pokémon by its name
charizard = Pokemon.find_by_name("Charizard")
puts charizard.type # Output: Fire
