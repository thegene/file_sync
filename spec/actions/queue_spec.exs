defmodule FileSync.Actions.QueueSpec do
  use ESpec

  alias FileSync.Actions.Queue

  context "Given a default Queue" do
    let queue: Queue.start_link() |> elem(1)

    it "starts empty" do
      queue()
      |> Queue.empty?
      |> expect
      |> to(be_true())
    end

    it "returns nil when empty" do
      queue()
      |> Queue.pop
      |> expect
      |> to(eq(nil))
    end

    context "when we add one thing to it" do
      before do: queue() |> Queue.push(thing())

      let thing: :foo

      it "is no longer empty" do
        queue()
        |> Queue.empty?
        |> expect
        |> to_not(be_true())
      end

      context "and pop an item off the queue" do
        let popped_item: queue() |> Queue.pop

        it "is the thing we enqueued" do
          popped_item()
          |> expect
          |> to(eq(:foo))
        end

        it "is now empty again" do
          popped_item()
          queue()
          |> Queue.empty?
          |> expect
          |> to(be_true())
        end
      end
    end

    context "when we add two things to it" do
      before do
        queue() |> Queue.push("first thing")
        queue() |> Queue.push("second thing")
      end

      it "is not empty" do
        queue()
        |> Queue.empty?
        |> expect
        |> not_to(be_true())
      end

      context "when we pop one of them off" do
        let first_item: queue() |> Queue.pop

        it "is the first thing" do
          first_item()
          |> expect
          |> to(eq("first thing"))
        end

        it "is not empty" do
          first_item()
          queue()
          |> Queue.empty?
          |> expect
          |> not_to(be_true())
        end

        context "when we pop again" do
          let :second_item do
            queue() |> Queue.pop
            queue() |> Queue.pop
          end

          it "is the second thing" do
            second_item()
            |> expect
            |> to(eq("second thing"))
          end

          it "is empty" do
            second_item()

            queue()
            |> Queue.empty?
            |> expect
            |> to(be_true())
          end

          context "if we pop a third time" do
            let :third_item do
              queue() |> Queue.pop
              queue() |> Queue.pop
              queue() |> Queue.pop
            end

            it "is nil" do
              third_item()
              |> expect
              |> to(be_nil())
            end
          end
        end
      end
    end
  end

  context "Given a queue with an initial value" do
    let queue: Queue.start_link(value: {:foo, {}}) |> elem(1)

    it "is not empty" do
      queue()
      |> Queue.empty?
      |> expect
      |> to(be_false())
    end
  end

  context "Given a named queue" do
    let queue: Queue.start_link(agent: [name: :bar]) |> elem(1)
    let found_queue: Queue.find_queue(:bar)

    it "can be found by name" do
      queue()
      |> expect
      |> to(eq(found_queue()))
    end
  end
end
