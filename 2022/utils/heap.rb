class MinHeap
  def initialize
    @tree = []
    @index = {}
    @priority = {}
  end

  def insert(thing, priority)
    if @index.key? thing
      update(thing, priority)
      return
    end

    @tree.push(thing)
    @index[thing] = @tree.length - 1
    @priority[thing] = priority
    bubble(@tree.length - 1)
  end

  def extract
    swap(0, @tree.length - 1)
    temp = @tree.pop
    @index.delete temp
    @priority.delete temp
    heapify

    temp
  end

  def update(thing, priority)
    old_priority = @priority[thing]

    if compare(priority, old_priority)
      heapify(@index[thing])
    else
      bubble(@index[thing])
    end
  end

  protected

  def bubble(i)
    return if i <= 0 || compare(priority(i), priority(parent(i)))
    swap(i, parent(i))
    bubble(parent(i))
  end

  def heapify(i=0)
    return if @tree[i].nil?

    heapify(left(i))
    heapify(right(i))

    swap(i, left(i)) if !@tree[left(i)].nil? && compare(priority(i), priority(left(i)))
    swap(i, right(i)) if !@tree[right(i)].nil? && compare(priority(i), priority(right(i)))
  end

  def swap(i, j)
    # swap in tree
    temp = @tree[i]
    @tree[i] = @tree[j]
    @tree[j] = temp

    # update lookup table
    @index[@tree[i]] = i
    @index[@tree[j]] = j
  end

  def compare(pi, pj) = pi >= pj

  def priority(i) = @priority[@tree[i]]
  
  def left(i) = 2 * i + 1

  def right(i) = 2 * i + 2

  def parent(i) = (i - 1) / 2
end

class MaxHeap < MinHeap
  protected

  def compare(pi, pj) = pi <= pj
end
