module Comparable
    def is_bigger_than?(node)
        self.data > node.data ? true : false
    end
end

module Cleanable
    def clean_duplicates(array)
        index = 1
        while index < array.length
            array.delete_at(index) if array[index] == array[index-1]
            index += 1
        end
        p array
    end
end

class Node
    include Comparable
    attr_reader :data
    def initialize (data, left_child = nil, right_child = nil)
        @data = data
        @left_child = left_child
        @right_child = right_child
    end
end

class Tree

    include Cleanable

    def initialize(array)
        @array = clean_duplicates(array.sort)
        @root = build_tree(@array)
    end

    def build_tree(array)
        first = 0
        last = array.length - 1
        mid = ((first + last) / 2).round()
        if first > last
            Node.new(array[mid])
        else
            Node.new(array[mid], set_left_child(array, first, mid-1), set_right_child(array, mid+1, last))
        end
    end

    def set_left_child(array, first, last)
        mid = ((first + last) / 2).round()
        if first > last
            nil
        else
            Node.new(array[mid], set_left_child(array, first, mid-1), set_right_child(array, mid+1, last))
        end
    end

    def set_right_child(array, first, last)
        mid = ((first + last) / 2).round()
        if first > last
            nil
        else
            Node.new(array[mid], set_left_child(array, first, mid-1), set_right_child(array, mid+1, last))
        end
    end
    
end

p Tree.new([1, 2, 3, 4, 4, 1, 9, 15, 3])

