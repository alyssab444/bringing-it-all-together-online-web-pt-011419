class Dog 
  attr_accessor :name, :breed 
  attr_reader :id 
  @@all = []
  def initialize(id: nil, name:, breed:)
    @id = id 
    @name = name 
    @breed = breed 
    @@all << self 
  end 
  
  def self.create_table 
     sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
        SQL
    DB[:conn].execute(sql)
  end 
  
  def self.drop_table 
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end 
  
  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    if self.id == nil
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    else
      update
    end
    self
  end
  
  def self.create(hash)
    new_dog = Dog.new(hash)
    new_dog.save
  end

def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name)
    result = nil
    Dog.all.each do |dog|
      if dog.id == row[0][0]
        result = dog
      end
    end
    result
  end
  
  def self.all
    @@all 
  end 
  
  def self.find_by_id(num)
    result = nil
    Dog.all.each do |dog|
      if dog.id == num
        result = dog
      end
    end
    result
  end
  
  def self.find_or_create_by(hash)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
    SQL
    row = DB[:conn].execute(sql, hash[:name], hash[:breed])
    result = nil
    if row[0] == nil
      result = Dog.create(hash)
    else
      result = Dog.find_by_id(row[0][0])
    end
    result
  end
  
  def self.new_from_db(array)
    hash = {:id => array[0], :name => array[1], :breed => array[2]}
    new_dog = Dog.new(hash)
  end
  
  def update
    sql = <<-SQL
      UPDATE dogs
      SET  name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
end 