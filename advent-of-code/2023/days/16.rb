require_relative "../spec_helper"

require "set"

class DaySixteen < Day
  Ray = Struct.new(:i, :j, :direction, :length) do
    DIRECTION = {
      up: [-1, 0],
      down: [1, 0],
      left: [0, -1],
      right: [0, 1],
    }

    OBSTACLE = ["/", "\\", "|", "-"]

    def self.in_bounds?(grid, i, j)
      i >= 0 && j >= 0 && i < grid.size && j < grid.first.size
    end

    def hash
      [i, j, direction].hash
    end

    def eql?(obj)
      obj.is_a?(Ray) && obj.hash == hash
    end

    def to_s
      "<Ray (#{i},#{j}) #{direction}>"
    end
    

    def move(n)
      di, dj = DIRECTION[direction].map { _1 * n }
      [i + di, j + dj]
    end

    def collide(grid, n)
      ni, nj = move(n)
      case grid.dig(ni, nj)
      in "/" if direction == :up then [Ray.new(ni, nj + 1, :right)]
      in "/" if direction == :down then [Ray.new(ni, nj - 1, :left)]
      in "/" if direction == :left then [Ray.new(ni + 1, nj, :down)]
      in "/" if direction == :right then [Ray.new(ni - 1, nj, :up)]

      in "\\" if direction == :up then [Ray.new(ni, nj - 1, :left)]
      in "\\" if direction == :down then [Ray.new(ni, nj + 1, :right)]
      in "\\" if direction == :left then [Ray.new(ni - 1, nj, :up)]
      in "\\" if direction == :right then [Ray.new(ni + 1, nj, :down)]

      in "|" if [:right, :left].include? direction then [Ray.new(ni - 1, nj, :up), Ray.new(ni + 1, nj, :down)]
      in "-" if [:up, :down].include? direction then [Ray.new(ni, nj - 1, :left), Ray.new(ni, nj + 1, :right)]
      else # we did pass over an obstacle, but it has no effect because of our direction
        ni, nj = move(n + 1)
        [Ray.new(ni, nj, direction)]
      end
    end

    # to process a ray is to find the next obstacle, and return the rays
    # that are produced from colliding with that obstacle. if there is 
    # nothing in the way, the ray disappears
    def process(grid)
      d = 0
      ni, nj = nil
      loop do
        ni, nj = move(d)

        break unless Ray.in_bounds?(grid, ni, nj)

        collision = OBSTACLE.include? grid.dig(ni, nj)
        if collision
          self.length = d
          return collide(grid, d).filter { Ray.in_bounds?(grid, _1.i, _1.j) } 
        end
        
        d += 1
      end

      self.length = d
      []
    end
  end


  def energize(grid, seen_rays)
    energized = Set.new
    seen_rays.each do |ray|
      energized.add([ray.i, ray.j])
      ray.length.times do |d|
        ni, nj = ray.move(d + 1)
        energized.add([ni, nj])
      end
    end
    energized.filter { Ray.in_bounds?(grid, *_1) }
  end

  def print_grid(grid, energized)
    grid.size.times do |i|
      row = ""
      grid.first.size.times do |j|
        if energized.include?([i, j])
          row << "#"
        else
          row << grid.dig(i, j)
        end
      end
      puts row
    end
  end

  def energized_total(grid, initial_ray)
    energized = Set.new
    seen_rays = Set.new
    active_rays = [initial_ray]
    while active_rays.any?
      ray = active_rays.shift
      seen_rays.add(ray)

      ray
        .process(grid)
        .each do |child_ray|
          next if seen_rays.include?(child_ray)

          active_rays.push(child_ray)
        end
    end

    energize(grid, seen_rays).size
  end

  def p1(path)
    grid = File
      .readlines(path, chomp: true)
      .map!(&:chars)

    energized_total(grid, Ray.new(0, 0, :right))
  end

  def p2(path)
    grid = File
      .readlines(path, chomp: true)
      .map!(&:chars)

    max = 0
    # assume it's MxM
    (0...grid.first.size).each do |i|
      max = [
        max,
        energized_total(grid, Ray.new(0, i, :down)),
        energized_total(grid, Ray.new(grid.size - 1, i, :up)),
        energized_total(grid, Ray.new(i, 0, :right)),
        energized_total(grid, Ray.new(i, grid.first.size - 1, :left))
      ].max
    end

    max
  end

  it { expect(p1("days/16_example.txt")).to eq(46) }
  it { expect(p1("days/16_input.txt")).to eq(7067) }

  it { expect(p2("days/16_example.txt")).to eq(51) }
  it { expect(p2("days/16_input.txt")).to eq(7324) }
end