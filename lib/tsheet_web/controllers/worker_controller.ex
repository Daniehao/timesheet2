defmodule TsheetWeb.WorkerController do
  use TsheetWeb, :controller

  alias Tsheet.Workers
  alias Tsheet.Workers.Worker

  action_fallback TsheetWeb.FallbackController

  plug TsheetWeb.Plugs.RequireAuth when action in [:create, :update, :delete, :timesheets]

  def index(conn, _params) do
    workers = Workers.list_workers()
    render(conn, "index.json", workers: workers)
  end

  def create(conn, %{"worker" => worker_params}) do
    with {:ok, %Worker{} = worker} <- Workers.create_worker(worker_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.worker_path(conn, :show, worker))
      |> render("show.json", worker: worker)
    end
  end

  def show(conn, %{"id" => id}) do
    worker = Workers.get_worker!(id)
    render(conn, "show.json", worker: worker)
  end

  def update(conn, %{"id" => id, "worker" => worker_params}) do
    worker = Workers.get_worker!(id)

    with {:ok, %Worker{} = worker} <- Workers.update_worker(worker, worker_params) do
      render(conn, "show.json", worker: worker)
    end
  end

  def delete(conn, %{"id" => id}) do
    worker = Workers.get_worker!(id)

    with {:ok, %Worker{}} <- Workers.delete_worker(worker) do
      send_resp(conn, :no_content, "")
    end
  end

  def timesheets(conn, %{"email" => email}) do
    IO.puts("timesheets getting")
    worker = Workers.get_worker_with_timesheets!(email)
    IO.puts("worker with timesheets")
    IO.inspect(worker)
    render(conn, "timesheets.json", worker: worker)
  end
end
