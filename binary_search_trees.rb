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

module Traversal

    def level_order()
        level_order_array = level_order_traversal(@root.data)
        block_given? ? yield(level_order_array) : level_order_array
    end

    def level_order_traversal(parent, queue=[parent] , array = [])
        if queue.empty?
            return array
        else
            parent = queue[0]
            array.push(parent)
            queue.push(find(parent).left_child.data) unless find(parent).left_child.nil?
            queue.push(find(parent).right_child.data) unless find(parent).right_child.nil?
            queue.shift()
            return level_order_traversal(parent, queue, array)
        end
    end

    def inorder(current = @root, array = [])
        if current.left_child.nil? || array.include?(current.left_child.data)
            array.push(current.data)
            array = inorder(current.right_child, array) unless current.right_child.nil?
        else
            array = inorder(current, inorder(current.left_child, array))
        end
        return array
    end

    def preorder(current = @root, array = [])
        array.push(current.data) unless array.include?(current.data)
        if current.left_child.nil? || array.include?(current.left_child.data)
            array = preorder(current.right_child, array) unless current.right_child.nil?
        else
            array = preorder(current, preorder(current.left_child, array))
        end
        return array
    end

    def postorder(current = @root, array = [])
        if current.left_child.nil? || array.include?(current.left_child.data)
            array = postorder(current.right_child, array) unless current.right_child.nil?
            array.push(current.data) unless array.include?(current.data)
        else
            array = postorder(current, postorder(current.left_child, array))
        end
        return array
    end

end

class Node
    include Comparable
    include Traversal
    attr_accessor :data, :left_child, :right_child
    def initialize (data, left_child = nil, right_child = nil)
        @data = data
        @left_child = left_child
        @right_child = right_child
    end

end

class Tree

    include Cleanable
    include Traversal
    attr_accessor :array

    def initialize(array)
        @array = clean_duplicates(array.sort)
        @root = build_tree(@array)
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

    def insert(data)
        current_node = @root
        inserted = false
        @array.push(data)
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
        @array.delete(data)
        if node.left_child.nil? && node.right_child.nil?
            if !parent.left_child.nil? && parent.left_child.data == data
                parent.left_child = nil
            else 
                parent.right_child = nil
            end
        elsif node.left_child.nil?            
            if !parent.left_child.nil? && parent.left_child.data == data
                parent.left_child = node.right_child
            else 
                parent.right_child = node.right_child
            end
        elsif node.right_child.nil?
            if !parent.left_child.nil? && parent.left_child.data == data
                parent.left_child = node.left_child
            else
                parent.right_child = node.left_child
            end
        else
            inorder_successor = inorder_successor_of(data)
            delete(inorder_successor.data)
            inorder_successor.left_child = node.left_child
            inorder_successor.right_child = node.right_child
            parent.left_child.data == data ? parent.left_child = inorder_successor : parent.right_child = inorder_successor
        end
        self
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

    def height(data)
        height = 0
        self.array.each do |leaf|
            leaf = find(leaf)
            break if leaf.nil?
            if leaf.left_child.nil? && leaf.right_child.nil?
                distance = 1
                until parent_of(leaf.data).data == data || parent_of(leaf.data) == @root do
                    leaf = parent_of(leaf.data)
                    distance += 1
                end
                if parent_of(leaf.data).data == data && distance > height
                    height = distance
                end
            end
        end
        height
    end

    def depth(data)
        distance = 0
        until @root.data == data do
            distance += 1
            data = parent_of(data).data
        end
        return distance
    end

    def balanced?()
        (self.height(@root.left_child.data) - self.height(@root.right_child.data)).abs > 1 ? false : true
    end

    def rebalance()
        Tree.new(self.array)
    end

end

puts "Testing the methods"
odin_tree = Tree.new(Array.new(15) { rand(1..100)})
p odin_tree.balanced?()
p odin_tree.preorder()
p odin_tree.inorder()
p odin_tree.postorder()
odin_tree.insert(101).insert(199).insert(148).insert(144).insert(177)
p odin_tree.balanced?()
odin_tree = odin_tree.rebalance()
p odin_tree.balanced?()
p odin_tree.preorder()
p odin_tree.inorder()
p odin_tree.postorder()

