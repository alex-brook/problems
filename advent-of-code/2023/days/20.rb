require_relative "../spec_helper"

require "set"
require "ruby-graphviz"

class DayTwenty < Day
  class Component
    def self.reset
      @@components = {}
      @@events = []
      @@low_pulses = 0
      @@high_pulses = 0
      @@rx_pulses = 0
    end

    def self.log(msg)
      # puts msg
    end

    def self.pulses
      [@@rx_pulses, @@low_pulses, @@high_pulses]
    end

    def self.events
      @@events
    end

    def self.all
      @@components.values
    end

    def self.[](label)
      @@components[label]
    end

    def self.build(line)
      label, outputs = line.split(" -> ")
      outputs = outputs.split(", ")

      if label[0] == "%"
        FlipFlop.new(label[1..], outputs)
      elsif label[0] == "&"
        Conjunction.new(label[1..], outputs)
      else
        Broadcaster.new(label, outputs)
      end
    end

    def self.button
      Component.log("button -low-> broadcaster")
      @@events.push([false, "button", "broadcaster"])
      @@low_pulses += 1
      while @@events.any?
        pulse, from, to = @@events.shift

        unless Component[to].nil?
          Component[to].execute_pulse(pulse, from)
        end
      end
    end

    attr_reader :outputs, :label

    def initialize(label, outputs)
      @label = label
      @outputs = outputs
      @@components[label] = self
    end

    def enqueue_pulses(pulse)
      @outputs.each do |output|
        Component.log("#{@label} -#{pulse ? 'high' : 'low'}-> #{output}")
        # binding.irb if output == "rx"
        if pulse
          @@high_pulses += 1
        elsif output == "rx"
          @@low_pulses += 1
          @@rx_pulses += 1
        else 
          @@low_pulses += 1
        end
        
        @@events.push([pulse, @label, output])
      end
    end

    def graph_label
      "#{self.class.name.split('::').last} (#{label})"
    end

  end

  class Broadcaster < Component
    def hash
      @label.hash
    end

    def eql?(obj)
      return false unless obj.is_a?(Broadcaster)

      obj.label == @label
    end

    def execute_pulse(pulse, _sender)
      enqueue_pulses(pulse)
    end
  end

  class FlipFlop < Component

    attr_reader :state
    def initialize(label, outputs)
      super
      @state = false
    end
    
    def hash
      [@label, state].hash
    end

    def eql?
      return false unless obj.is_a?(FlipFlop)

      obj.label == @label && obj.state == @state
    end

    def execute_pulse(pulse, _sender)
      return if pulse
      @state = !@state
      enqueue_pulses(@state)
    end
  end

  class Conjunction < Component
    def execute_pulse(pulse, sender)
      state[sender] = pulse
      enqueue_pulses(!state.values.all?)
    end

    def hash
      [@label, state].hash
    end

    def eql?(obj)
      return false unless obj.is_a?(Conjunction)

      obj.label == @label && obj.state == state
    end

    def state
      @state ||= begin
        Component
          .all
          .filter { _1.outputs.include?(@label) }
          .to_h { |input| [input.label, false] }
      end
    end
  end

  def parse_input(path)
    File
      .readlines(path, chomp: true)
      .tap { Component.reset }
      .map! { Component.build(_1) }
  end

  def p1(path)
    components = parse_input(path)

    seen = Set.new([components.hash])
    loop do
      Component.button
      break if seen.size >= 1000 || seen.include?(components.hash)
      seen.add(components.hash)
    end

    Component.pulses.drop(1).map { _1 * (1000 / seen.size) }.reduce(&:*)
  end

  def draw_graph
    g = GraphViz.new(:G, type: :digraph)
    Component.all.each { g.add_nodes(_1.graph_label) }
    Component.all.each do |component|
      component.outputs.each do |output|
        g.add_edges(component.graph_label, Component[output]&.graph_label || output)
      end
    end
    g.output({ png: "days/20_viz.png"})
  end

  def p2(path)
    components = parse_input(path)
    draw_graph
  end

  it { expect(p1("days/20_example_01.txt")).to eq(32000000) }
  it { expect(p1("days/20_example_02.txt")).to eq(11687500) }
  it { expect(p1("days/20_input.txt")).to eq(681194780) }

  # it { expect(p2("days/20_input.txt")).to eq(0) }
end