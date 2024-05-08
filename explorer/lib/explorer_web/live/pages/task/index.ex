defmodule ExplorerWeb.Task.Index do
  use ExplorerWeb, :live_view

  def mount(params, session, socket) do
    ExplorerWeb.Task.Controller.mount(params, session, socket)
  end

  def render(assigns) do
    ~H"""
      <div class="flex flex-col space-y-3 bg-zinc-200 dark:bg-zinc-900 rounded-2xl px-6 py-8 min-h-[40rem] text-foreground max-w-96 md:max-w-5xl mx-auto capitalize">
        <%= if not @isTaskEmpty do %>
          <h1 class="text-5xl font-bold">Task #<%= @id %></h1>
          <p class="font-semibold">
            address: <span class="break-all font-normal"><%= @task.address %></span>
          </p>
          <p class="font-semibold">
            block hash: <span class="break-all font-normal"><%= @task.block_hash %></span>
          </p>
          <p class="font-semibold">
            block number: <span class="break-all font-normal"><%= @task.block_number %></span>
          </p>
          <p class="font-semibold">
            transaction hash: <span class="break-all font-normal"><%= @task.transaction_hash %></span>
          </p>

          <div class="capitalize flex flex-col space-y-3">
            <h2 class="text-3xl font-bold">Aligned Task</h2>
            <p class="font-semibold">
              proving system ID:
              <span class="break-all font-normal"><%= @task.aligned_task.verificationSystemId %></span>
            </p>
            <%!-- <p class="font-semibold" class="break-all">
              Proof:
              <span class="break-all font-normal select-all"><%= @task.aligned_task.proof %></span>
            </p> --%>
            <p class="font-semibold">
              pub Input: <span class="break-all font-normal"><%= @task.aligned_task.pubInput %></span>
            </p>
            <p class="font-semibold">
              Task Created Block:
              <span class="break-all font-normal"><%= @task.aligned_task.taskCreatedBlock %></span>
            </p>
          </div>

          <div class="capitalize flex flex-col space-y-3">
            <h2 class="text-3xl font-bold">Aligned Task Response</h2>
            <%= if not @isTaskResponseEmpty do %>
              <p class="font-semibold">
                address: <span class="break-all font-normal"><%= @taskResponse.address %></span>
              </p>
              <p class="font-semibold">
                block hash: <span class="break-all font-normal"><%= @taskResponse.block_hash %></span>
              </p>
              <p class="font-semibold">
                block number:
                <span class="break-all font-normal"><%= @taskResponse.block_number %></span>
              </p>
              <p class="font-semibold">
                task Id: <span class="break-all font-normal"><%= @taskResponse.taskId %></span>
              </p>
              <p class="font-semibold">
                transaction hash:
                <span class="break-all font-normal"><%= @taskResponse.transaction_hash %></span>
              </p>
              <p class="font-semibold">
                Is the proof correct?
                <span class="break-all font-normal"><%= @taskResponse.proofIsCorrect %></span>
              </p>
            <% else %>
              <p class="text-left my-auto">The task #<%= @id %> doesn't seem to have a response 🫤</p>
            <% end %>
          </div>
        <% else %>
          <div class="flex flex-col space-y-6 justify-center grow relative text-center">
            <h1 class="text-5xl font-semibold">Oops!</h1>
            <h2 class="text-xl font-medium">
              The task you are looking for doesn't exist. <br /> Please try another task ID.
            </h2>
            <img
              class="z-0 w-64 rounded-xl mx-auto"
              alt="block not found"
              src={~p"/images/not-found.jpeg"}
            />
          </div>
        <% end %>
      </div>
    """
  end
end
