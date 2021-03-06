defmodule Phoenix.LiveDashboard.MetricsLive do
  use Phoenix.LiveDashboard.Web, :live_view

  alias Phoenix.LiveDashboard.ChartComponent

  @impl true
  def mount(params, %{"metrics" => {mod, fun}} = session, socket) do
    all_metrics = apply(mod, fun, [])
    metrics_per_group = Enum.group_by(all_metrics, &group_name/1)

    group = params["group"]
    metrics = metrics_per_group[group]

    socket =
      socket
      |> assign_defaults(params, session)
      |> assign(group: group, groups: Map.keys(metrics_per_group))

    if metrics && connected?(socket) do
      Phoenix.LiveDashboard.Listener.listen(find_node!(socket.assigns.node), metrics)
      :net_kernel.monitor_nodes(true, node_type: :all)
      {:ok, assign(socket, metrics: Enum.with_index(metrics))}
    else
      {:ok, assign(socket, metrics: nil)}
    end
  end

  defp group_name(metric) do
    to_string(metric.reporter_options[:group] || hd(metric.name))
  end

  @impl true
  def render(assigns) do
    ~L"""
    <ul>
      <%= for group <- @groups do %>
        <li class="<%= if @group == group, do: "active" %>">
          <%= live_redirect "#{inspect(group)} metrics",
                to: live_dashboard_path(@socket, :metrics, @node, [group]) %>
        </li>
      <% end %>
    </ul>

    <%= if @metrics do %>
      <div class="phx-dashboard-metrics-grid">
      <%= for {metric, id} <- @metrics do %>
        <%= live_component @socket, ChartComponent, id: id, metric: metric %>
      <% end %>
      </div>
    <% end %>
    """
  end

  @impl true
  def handle_info({:telemetry, entries}, socket) do
    for {id, label, measurement, time} <- entries do
      data = [%{x: label, y: measurement, z: DateTime.from_unix!(time, :millisecond)}]
      send_update(ChartComponent, id: id, data: data)
    end

    {:noreply, socket}
  end

  def handle_info({:node_redirect, node}, socket) do
    {:noreply, push_redirect(socket, to: live_dashboard_path(socket, :metrics, node))}
  end

  defp find_node!(param_node) do
    Enum.find([node() | Node.list()], &(Atom.to_string(&1) == param_node)) ||
      raise "could not find #{param_node}"
  end
end
