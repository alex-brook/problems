require_relative "../spec_helper"

# only passes p1 example
class DaySixteen < Day
  Graph = Struct.new(:flow, :tunnels)
  def solve(filename)
    graph = File
      .readlines(filename, chomp: true)
      .reduce(Graph.new({}, {})) do |graph, line|
        line.scan(/[A-Z]{2}/) in [node, *out]
        line.scan(/flow rate=(\d+)/) in [[flow]]
      
        graph.flow[node] = flow.to_i
        graph.tunnels[node] = out

        graph 
      end

    dist = floyd_warshall(graph)
    useful = graph.flow.filter_map { |node, flow| node if flow.positive? }

    search(graph, dist, useful, 30, "AA")
  end

  def search(graph, dist, remaining, time, node, path = [])
    time -= 1 unless node == "AA"
    potential = graph.flow[node] * time

    remaining
      .filter { |next_node| time - dist[[node, next_node]] > 0 }
      .map do |next_node|
        [next_node, search(
          graph,
          dist,
          remaining - [next_node],
          time - dist[[node, next_node]],
          next_node,
          path)]
      end
      .max_by(&:last) in [next_node, cost]

    potential + (cost || 0)
  end

  def floyd_warshall(graph)
    dist = Hash.new(Float::INFINITY)

    graph
      .tunnels
      .flat_map do |source_node, destination_nodes|
        destination_nodes.map do |destination_node|
          dist[[source_node, destination_node]] = 1
        end
      end

    nodes = graph.tunnels.keys

    nodes.each do |source_node|
      dist[[source_node, source_node]] = 0
    end

    nodes
      .permutation(3)
      .each do |(i, j, k)|
        dist[[i,j]] = dist[[i,k]] + dist[[k,j]] if dist[[i,j]] > dist[[i,k]] + dist[[k,j]] 
      end

    dist
  end

  it { expect(solve("days/16_example.txt")).to eq 1651 }
  # it { expect(solve("days/16_input.txt")).to eq 0 }
end
