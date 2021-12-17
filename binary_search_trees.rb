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
        array
    end
end

class Node
    include Comparable
    attr_accessor :data, :left_child, :right_child
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

    def insert(data)
        current_node = @root
        inserted = false
        until inserted do
            if current_node.data < data && current_node.right_child.nil?
                current_node.right_child = Node.new(data)
                inserted = true
            elsif current_node.data < data
                current_node = current_node.right_child
            elsif current_node.data > data && current_node.left_child.nil?
                current_node.left_child = Node.new(data)
                inserted = true
            elsif current_node.data > data
                current_node = current_node.left_child
            else
                return self
            end
        end
        self
    end

    def find(data)
        current_node = @root
        not_found = false
        until not_found
            if current_node.data == data
                return current_node
            elsif current_node.data < data && current_node.right_child.nil?
                not_found = true
            elsif current_node.data < data
                current_node = current_node.right_child
            elsif current_node.data > data && current_node.left_child.nil?
                not_found = true
            elsif current_node.data > data
                current_node = current_node.left_child
            end
        end
        nil
    end

    def parent_of(data)
        parent = @root
        current_node = @root
        not_found = false
        until not_found
            if current_node.data == data
                return parent
            elsif current_node.data < data && current_node.right_child.nil?
                not_found = true
            elsif current_node.data < data
                parent = current_node
                current_node = current_node.right_child
            elsif current_node.data > data && current_node.left_child.nil?
                not_found = true
            elsif current_node.data > data
                parent = current_node
                current_node = current_node.left_child
            end
        end
        nil
    end

    def inorder_successor_of(data)
        node = find(data)
        current = node.right_child
        until current.left_child.nil?
            current = current.left_child
        end
        return current
    end

    def delete(data)
        node = find(data)
        parent = parent_of(data)
        return nil if node.nil? || node == @root
        if node.left_child.nil? && node.right_child.nil?
            parent.left_child.data == data ? parent.left_child = nil : parent.right_child = nil
        elsif node.left_child.nil?
            parent.left_child.data == data ? parent.left_child = node.right_child : parent.right_child = node.right_child
        elsif node.right_child.nil?
            parent.left_child.data == data ? parent.left_child = node.left_child : parent.right_child = node.left_child
        else
            inorder_successor = inorder_successor_of(data)
            delete(inorder_successor.data)
            inorder_successor.left_child = node.left_child
            inorder_successor.right_child = node.right_child
            parent.left_child.data == data ? parent.left_child = inorder_successor : parent.right_child = inorder_successor
        end
        self
    end

    def level_order(&level_order)
        level_order_array = level_order_traversal([@root])
        if block_given?
            level_order_array.each do
                yield node
            end
        else
            return level_order
        end
    end

    level_order(node) { node.data }

    def level_order_traversal(parents)
        array = []
        queue = []
        until parents.length < 1 do
            parents.each_with_index do |parent, index|
                array.push(parent)
                unless parent.left_child.nil?
                    queue.push(parent.left_child) 
                end
                unless parent.right_child.nil? 
                    queue.push(parent.right_child)
                end
                parents.delete_at(index)
            end
                parents += queue
                queue = []
        end
        return array
    end
    
end
p Tree.new([17,44,28,29,88,97,65,54,82,76,80,78]).level_order
