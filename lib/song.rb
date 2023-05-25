require 'sqlite3'

class Song
  attr_accessor :name, :album, :id

  def initialize(name:, album:, id: nil)
    @id = id
    @name = name
    @album = album
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS songs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        album TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO songs (name, album)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.album)
    @id = DB[:conn].last_insert_row_id
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM songs
      WHERE id = ?
    SQL

    result = DB[:conn].execute(sql, id)[0]
    self.new_from_db(result) if result
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM songs
      WHERE name = ?
    SQL

    result = DB[:conn].execute(sql, name)[0]
    self.new_from_db(result) if result
  end

  def self.new_from_db(row)
    id, name, album = row
    self.new(name: name, album: album, id: id)
  end

  def self.all
    sql = <<-SQL
      SELECT * FROM songs
    SQL

    rows = DB[:conn].execute(sql)
    rows.map { |row| self.new_from_db(row) }
  end
end

DB = { conn: SQLite3::Database.new("db/music.db") }

Song.create_table
