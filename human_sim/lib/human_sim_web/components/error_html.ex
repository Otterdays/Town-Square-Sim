defmodule HumanSimWeb.ErrorHTML do
  use HumanSimWeb, :html

  def render("404.html", _assigns) do
    "Page not found"
  end

  def render("500.html", _assigns) do
    "Internal server error"
  end
end
