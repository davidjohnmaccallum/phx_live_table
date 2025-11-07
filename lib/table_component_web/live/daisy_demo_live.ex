defmodule TableComponentWeb.DaisyDemoLive do
  use TableComponentWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:selected_tab, "buttons")
     |> assign(:checkbox_checked, false)
     |> assign(:toggle_checked, true)
     |> assign(:radio_value, "option1")
     |> assign(:range_value, 50)
     |> assign(:modal_open, false)
     |> assign(:drawer_open, false)
     |> assign(:loading, false)
     |> assign(:toast_visible, false)
     |> assign(:selected_options, MapSet.new())}
  end

  def handle_event("select_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :selected_tab, tab)}
  end

  def handle_event("toggle_checkbox", _params, socket) do
    {:noreply, assign(socket, :checkbox_checked, !socket.assigns.checkbox_checked)}
  end

  def handle_event("toggle_switch", _params, socket) do
    {:noreply, assign(socket, :toggle_checked, !socket.assigns.toggle_checked)}
  end

  def handle_event("change_radio", %{"value" => value}, socket) do
    {:noreply, assign(socket, :radio_value, value)}
  end

  def handle_event("change_range", %{"value" => value}, socket) do
    {:noreply, assign(socket, :range_value, String.to_integer(value))}
  end

  def handle_event("open_modal", _params, socket) do
    {:noreply, assign(socket, :modal_open, true)}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, :modal_open, false)}
  end

  def handle_event("toggle_drawer", _params, socket) do
    {:noreply, assign(socket, :drawer_open, !socket.assigns.drawer_open)}
  end

  def handle_event("simulate_loading", _params, socket) do
    send(self(), :stop_loading)
    {:noreply, assign(socket, :loading, true)}
  end

  def handle_event("show_toast", _params, socket) do
    send(self(), :hide_toast)
    {:noreply, assign(socket, :toast_visible, true)}
  end

  def handle_event("toggle_multi_select", %{"value" => value}, socket) do
    selected_options = socket.assigns.selected_options

    new_selected =
      if MapSet.member?(selected_options, value) do
        MapSet.delete(selected_options, value)
      else
        MapSet.put(selected_options, value)
      end

    {:noreply, assign(socket, :selected_options, new_selected)}
  end

  def handle_info(:stop_loading, socket) do
    Process.sleep(2000)
    {:noreply, assign(socket, :loading, false)}
  end

  def handle_info(:hide_toast, socket) do
    Process.sleep(3000)
    {:noreply, assign(socket, :toast_visible, false)}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-base-200">
      <!-- Hero Section - 1970s IBM System/360 Style -->
      <div class="bg-primary text-primary-content border-b-8 border-neutral">
        <div class="container mx-auto px-4 py-8">
          <div class="max-w-4xl">
            <div class="flex items-start gap-6 mb-6">
              <!-- IBM Logo Box -->
              <div class="flex-shrink-0">
                <div class="w-24 h-24 bg-base-100 border-4 border-neutral flex items-center justify-center shadow-lg">
                  <span
                    class="text-4xl font-black text-primary"
                    style="font-family: 'Courier New', monospace; letter-spacing: 0.1em;"
                  >
                    IBM
                  </span>
                </div>
              </div>
              <!-- Title Area -->
              <div class="flex-1">
                <div class="inline-block bg-base-100 text-neutral px-6 py-2 mb-3 border-2 border-neutral">
                  <span class="text-sm font-bold" style="font-family: 'Courier New', monospace; letter-spacing: 0.2em;">
                    SYSTEM 360
                  </span>
                </div>
                <h1
                  class="text-4xl font-bold tracking-tight uppercase mb-2"
                  style="font-family: 'Courier New', monospace; text-shadow: 2px 2px 0px rgba(0,0,0,0.2);"
                >
                  Business Systems
                </h1>
                <p class="text-lg opacity-95 mb-2 font-semibold">Component Library Demonstration</p>
                <p class="text-sm opacity-85" style="font-family: 'Courier New', monospace;">
                  Professional interface components • Corporate aesthetic • 1970s inspired design
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Main Content -->
      <div class="container mx-auto px-4 py-8">
        <!-- Tabs Navigation - 1970s Style -->
        <div class="bg-base-100 border-2 border-base-300 mb-8 shadow-lg">
          <div class="flex border-b-2 border-base-300">
            <button
              class={[
                "px-6 py-3 font-semibold uppercase tracking-wide text-sm transition-colors border-r-2 border-base-300",
                @selected_tab == "buttons" && "bg-primary text-primary-content",
                @selected_tab != "buttons" && "bg-base-100 hover:bg-base-200"
              ]}
              phx-click="select_tab"
              phx-value-tab="buttons"
              style="font-family: 'Courier New', monospace;"
            >
              Buttons
            </button>
            <button
              class={[
                "px-6 py-3 font-semibold uppercase tracking-wide text-sm transition-colors border-r-2 border-base-300",
                @selected_tab == "forms" && "bg-primary text-primary-content",
                @selected_tab != "forms" && "bg-base-100 hover:bg-base-200"
              ]}
              phx-click="select_tab"
              phx-value-tab="forms"
              style="font-family: 'Courier New', monospace;"
            >
              Forms
            </button>
            <button
              class={[
                "px-6 py-3 font-semibold uppercase tracking-wide text-sm transition-colors border-r-2 border-base-300",
                @selected_tab == "cards" && "bg-primary text-primary-content",
                @selected_tab != "cards" && "bg-base-100 hover:bg-base-200"
              ]}
              phx-click="select_tab"
              phx-value-tab="cards"
              style="font-family: 'Courier New', monospace;"
            >
              Cards
            </button>
            <button
              class={[
                "px-6 py-3 font-semibold uppercase tracking-wide text-sm transition-colors border-r-2 border-base-300",
                @selected_tab == "alerts" && "bg-primary text-primary-content",
                @selected_tab != "alerts" && "bg-base-100 hover:bg-base-200"
              ]}
              phx-click="select_tab"
              phx-value-tab="alerts"
              style="font-family: 'Courier New', monospace;"
            >
              Alerts
            </button>
            <button
              class={[
                "px-6 py-3 font-semibold uppercase tracking-wide text-sm transition-colors",
                @selected_tab == "modals" && "bg-primary text-primary-content",
                @selected_tab != "modals" && "bg-base-100 hover:bg-base-200"
              ]}
              phx-click="select_tab"
              phx-value-tab="modals"
              style="font-family: 'Courier New', monospace;"
            >
              Modals
            </button>
          </div>
        </div>

        <!-- Tab Content -->
        <div class="space-y-8">
          <%= if @selected_tab == "buttons" do %>
            <.button_section />
          <% end %>

          <%= if @selected_tab == "forms" do %>
            <.form_section
              checkbox_checked={@checkbox_checked}
              toggle_checked={@toggle_checked}
              radio_value={@radio_value}
              range_value={@range_value}
              selected_options={@selected_options}
            />
          <% end %>

          <%= if @selected_tab == "cards" do %>
            <.card_section />
          <% end %>

          <%= if @selected_tab == "alerts" do %>
            <.alert_section />
          <% end %>

          <%= if @selected_tab == "modals" do %>
            <.modal_section
              modal_open={@modal_open}
              drawer_open={@drawer_open}
              loading={@loading}
              toast_visible={@toast_visible}
            />
          <% end %>
        </div>
      </div>

      <!-- Toast Notification -->
      <%= if @toast_visible do %>
        <div class="toast toast-top toast-end">
          <div class="alert alert-success border-4 border-success">
            <span style="font-family: 'Courier New', monospace;">
              ✓ OPERATION COMPLETED SUCCESSFULLY
            </span>
          </div>
        </div>
      <% end %>

      <!-- Drawer -->
      <%= if @drawer_open do %>
        <div class="drawer drawer-end drawer-open fixed inset-0 z-50">
          <input type="checkbox" class="drawer-toggle" checked />
          <div class="drawer-side">
            <label class="drawer-overlay bg-neutral/80" phx-click="toggle_drawer"></label>
            <div class="w-80 min-h-full bg-base-100 border-l-8 border-neutral shadow-2xl">
              <div class="bg-neutral text-neutral-content p-4 border-b-4 border-base-300">
                <h2
                  class="text-xl font-bold uppercase tracking-wide"
                  style="font-family: 'Courier New', monospace;"
                >
                  System Menu
                </h2>
              </div>
              <ul class="menu p-4 text-base-content">
                <li>
                  <a class="hover:bg-primary hover:text-primary-content border-b-2 border-base-300">
                    Item 1
                  </a>
                </li>
                <li>
                  <a class="hover:bg-primary hover:text-primary-content border-b-2 border-base-300">
                    Item 2
                  </a>
                </li>
                <li>
                  <a class="hover:bg-primary hover:text-primary-content border-b-2 border-base-300">
                    Item 3
                  </a>
                </li>
                <li>
                  <a class="hover:bg-primary hover:text-primary-content border-b-2 border-base-300">
                    Item 4
                  </a>
                </li>
              </ul>
              <div class="p-4">
                <button
                  class="btn btn-primary w-full"
                  phx-click="toggle_drawer"
                  style="font-family: 'Courier New', monospace;"
                >
                  CLOSE
                </button>
              </div>
            </div>
          </div>
        </div>
      <% end %>

      <!-- Modal -->
      <%= if @modal_open do %>
        <div class="modal modal-open">
          <div class="modal-box bg-base-100 border-8 border-neutral max-w-2xl shadow-2xl">
            <div class="bg-neutral text-neutral-content px-4 py-3 -mx-6 -mt-6 mb-4 border-b-4 border-base-300">
              <h3
                class="font-bold text-lg uppercase tracking-wide"
                style="font-family: 'Courier New', monospace;"
              >
                System Message
              </h3>
            </div>
            <p class="py-4 text-base" style="font-family: 'Courier New', monospace;">
              This is a daisyUI modal component styled with authentic 1970s IBM System/360 aesthetics.
              Professional, functional, and timeless.
            </p>
            <div class="modal-action">
              <button
                class="btn btn-ghost border-2 border-base-300"
                phx-click="close_modal"
                style="font-family: 'Courier New', monospace;"
              >
                CANCEL
              </button>
              <button
                class="btn btn-primary"
                phx-click="close_modal"
                style="font-family: 'Courier New', monospace;"
              >
                ACCEPT
              </button>
            </div>
          </div>
          <label class="modal-backdrop bg-neutral/80" phx-click="close_modal"></label>
        </div>
      <% end %>
    </div>
    """
  end

  # Component Sections

  defp button_section(assigns) do
    ~H"""
    <div class="bg-base-100 border-4 border-base-300 shadow-lg">
      <div class="border-b-4 border-base-300 bg-neutral text-neutral-content px-6 py-3">
        <h2 class="text-xl font-bold uppercase tracking-wide" style="font-family: 'Courier New', monospace;">
          Buttons
        </h2>
      </div>
      <div class="p-6">

        <div class="space-y-6">
          <!-- Button Colors -->
          <div>
            <h3 class="text-lg font-semibold mb-3">Button Colors</h3>
            <div class="flex flex-wrap gap-2">
              <button class="btn">Default</button>
              <button class="btn btn-neutral">Neutral</button>
              <button class="btn btn-primary">Primary</button>
              <button class="btn btn-secondary">Secondary</button>
              <button class="btn btn-accent">Accent</button>
              <button class="btn btn-ghost">Ghost</button>
              <button class="btn btn-link">Link</button>
            </div>
          </div>

          <!-- Button States -->
          <div>
            <h3 class="text-lg font-semibold mb-3">Button States</h3>
            <div class="flex flex-wrap gap-2">
              <button class="btn btn-info">Info</button>
              <button class="btn btn-success">Success</button>
              <button class="btn btn-warning">Warning</button>
              <button class="btn btn-error">Error</button>
              <button class="btn btn-disabled" disabled>Disabled</button>
            </div>
          </div>

          <!-- Button Sizes -->
          <div>
            <h3 class="text-lg font-semibold mb-3">Button Sizes</h3>
            <div class="flex flex-wrap items-center gap-2">
              <button class="btn btn-xs">Extra Small</button>
              <button class="btn btn-sm">Small</button>
              <button class="btn">Normal</button>
              <button class="btn btn-lg">Large</button>
            </div>
          </div>

          <!-- Button Shapes -->
          <div>
            <h3 class="text-lg font-semibold mb-3">Button Shapes</h3>
            <div class="flex flex-wrap gap-2">
              <button class="btn btn-square">
                <.icon name="hero-star" class="w-6 h-6" />
              </button>
              <button class="btn btn-circle">
                <.icon name="hero-heart" class="w-6 h-6" />
              </button>
              <button class="btn btn-wide">Wide Button</button>
            </div>
          </div>

          <!-- Button with Icons -->
          <div>
            <h3 class="text-lg font-semibold mb-3">Buttons with Icons</h3>
            <div class="flex flex-wrap gap-2">
              <button class="btn btn-primary">
                <.icon name="hero-rocket-launch" class="w-5 h-5" />
                Launch
              </button>
              <button class="btn btn-success">
                <.icon name="hero-check" class="w-5 h-5" />
                Approve
              </button>
              <button class="btn btn-error">
                <.icon name="hero-trash" class="w-5 h-5" />
                Delete
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp form_section(assigns) do
    ~H"""
    <div class="bg-base-100 border-4 border-base-300 shadow-lg">
      <div class="border-b-4 border-base-300 bg-neutral text-neutral-content px-6 py-3">
        <h2 class="text-xl font-bold uppercase tracking-wide" style="font-family: 'Courier New', monospace;">
          Form Components
        </h2>
      </div>
      <div class="p-6">

        <div class="space-y-6">
          <!-- Text Inputs -->
          <div>
            <h3 class="text-lg font-semibold mb-3">Text Inputs</h3>
            <div class="space-y-2">
              <input type="text" placeholder="Default input" class="input input-bordered w-full" />
              <input
                type="text"
                placeholder="Primary input"
                class="input input-bordered input-primary w-full"
              />
              <input
                type="text"
                placeholder="Success input"
                class="input input-bordered input-success w-full"
              />
              <input
                type="text"
                placeholder="Error input"
                class="input input-bordered input-error w-full"
              />
            </div>
          </div>

          <!-- Checkboxes -->
          <div>
            <h3 class="text-lg font-semibold mb-3">Checkboxes</h3>
            <div class="flex flex-wrap gap-4">
              <div class="form-control">
                <label class="label cursor-pointer gap-2">
                  <span class="label-text">Interactive Checkbox</span>
                  <input
                    type="checkbox"
                    class="checkbox"
                    checked={@checkbox_checked}
                    phx-click="toggle_checkbox"
                  />
                </label>
              </div>
              <div class="form-control">
                <label class="label cursor-pointer gap-2">
                  <span class="label-text">Primary</span>
                  <input type="checkbox" class="checkbox checkbox-primary" checked />
                </label>
              </div>
              <div class="form-control">
                <label class="label cursor-pointer gap-2">
                  <span class="label-text">Success</span>
                  <input type="checkbox" class="checkbox checkbox-success" checked />
                </label>
              </div>
              <div class="form-control">
                <label class="label cursor-pointer gap-2">
                  <span class="label-text">Warning</span>
                  <input type="checkbox" class="checkbox checkbox-warning" checked />
                </label>
              </div>
            </div>
          </div>

          <!-- Toggle -->
          <div>
            <h3 class="text-lg font-semibold mb-3">Toggles</h3>
            <div class="flex flex-wrap gap-4">
              <div class="form-control">
                <label class="label cursor-pointer gap-2">
                  <span class="label-text">Interactive Toggle</span>
                  <input
                    type="checkbox"
                    class="toggle"
                    checked={@toggle_checked}
                    phx-click="toggle_switch"
                  />
                </label>
              </div>
              <div class="form-control">
                <label class="label cursor-pointer gap-2">
                  <span class="label-text">Primary</span>
                  <input type="checkbox" class="toggle toggle-primary" checked />
                </label>
              </div>
              <div class="form-control">
                <label class="label cursor-pointer gap-2">
                  <span class="label-text">Success</span>
                  <input type="checkbox" class="toggle toggle-success" checked />
                </label>
              </div>
            </div>
          </div>

          <!-- Radio Buttons -->
          <div>
            <h3 class="text-lg font-semibold mb-3">Radio Buttons</h3>
            <div class="flex flex-wrap gap-4">
              <div class="form-control">
                <label class="label cursor-pointer gap-2">
                  <span class="label-text">Option 1</span>
                  <input
                    type="radio"
                    class="radio"
                    name="radio-demo"
                    checked={@radio_value == "option1"}
                    phx-click="change_radio"
                    phx-value-value="option1"
                  />
                </label>
              </div>
              <div class="form-control">
                <label class="label cursor-pointer gap-2">
                  <span class="label-text">Option 2</span>
                  <input
                    type="radio"
                    class="radio radio-primary"
                    name="radio-demo"
                    checked={@radio_value == "option2"}
                    phx-click="change_radio"
                    phx-value-value="option2"
                  />
                </label>
              </div>
              <div class="form-control">
                <label class="label cursor-pointer gap-2">
                  <span class="label-text">Option 3</span>
                  <input
                    type="radio"
                    class="radio radio-success"
                    name="radio-demo"
                    checked={@radio_value == "option3"}
                    phx-click="change_radio"
                    phx-value-value="option3"
                  />
                </label>
              </div>
            </div>
          </div>

          <!-- Range Slider -->
          <div>
            <h3 class="text-lg font-semibold mb-3">Range Slider</h3>
            <div class="space-y-2">
              <div class="flex items-center gap-4">
                <input
                  type="range"
                  min="0"
                  max="100"
                  value={@range_value}
                  class="range range-primary"
                  phx-change="change_range"
                />
                <span class="badge badge-primary">{@range_value}</span>
              </div>
            </div>
          </div>

          <!-- Select -->
          <div>
            <h3 class="text-lg font-semibold mb-3">Select</h3>
            <select class="select select-bordered w-full max-w-xs">
              <option disabled selected>Choose an option</option>
              <option>Option 1</option>
              <option>Option 2</option>
              <option>Option 3</option>
            </select>
          </div>

          <!-- Multi-Select -->
          <div>
            <h3 class="text-lg font-semibold mb-3">Multi-Select (Checkbox Group)</h3>
            <div class="border-2 border-base-300 bg-base-100 p-4 max-w-xs space-y-2">
              <div class="form-control">
                <label class="label cursor-pointer justify-start gap-3">
                  <input
                    type="checkbox"
                    class="checkbox checkbox-primary"
                    checked={MapSet.member?(@selected_options, "database")}
                    phx-click="toggle_multi_select"
                    phx-value-value="database"
                  />
                  <span class="label-text">Database Systems</span>
                </label>
              </div>
              <div class="form-control">
                <label class="label cursor-pointer justify-start gap-3">
                  <input
                    type="checkbox"
                    class="checkbox checkbox-primary"
                    checked={MapSet.member?(@selected_options, "networking")}
                    phx-click="toggle_multi_select"
                    phx-value-value="networking"
                  />
                  <span class="label-text">Networking</span>
                </label>
              </div>
              <div class="form-control">
                <label class="label cursor-pointer justify-start gap-3">
                  <input
                    type="checkbox"
                    class="checkbox checkbox-primary"
                    checked={MapSet.member?(@selected_options, "mainframe")}
                    phx-click="toggle_multi_select"
                    phx-value-value="mainframe"
                  />
                  <span class="label-text">Mainframe Computing</span>
                </label>
              </div>
              <div class="form-control">
                <label class="label cursor-pointer justify-start gap-3">
                  <input
                    type="checkbox"
                    class="checkbox checkbox-primary"
                    checked={MapSet.member?(@selected_options, "terminals")}
                    phx-click="toggle_multi_select"
                    phx-value-value="terminals"
                  />
                  <span class="label-text">Terminal Systems</span>
                </label>
              </div>
              <div class="form-control">
                <label class="label cursor-pointer justify-start gap-3">
                  <input
                    type="checkbox"
                    class="checkbox checkbox-primary"
                    checked={MapSet.member?(@selected_options, "storage")}
                    phx-click="toggle_multi_select"
                    phx-value-value="storage"
                  />
                  <span class="label-text">Storage Solutions</span>
                </label>
              </div>
              <%= if MapSet.size(@selected_options) > 0 do %>
                <div class="mt-3 pt-3 border-t-2 border-base-300">
                  <p class="text-sm font-semibold mb-2" style="font-family: 'Courier New', monospace;">
                    Selected: {MapSet.size(@selected_options)}
                  </p>
                  <div class="flex flex-wrap gap-1">
                    <%= for option <- Enum.sort(MapSet.to_list(@selected_options)) do %>
                      <div class="badge badge-primary badge-sm">{option}</div>
                    <% end %>
                  </div>
                </div>
              <% end %>
            </div>
          </div>

          <!-- Textarea -->
          <div>
            <h3 class="text-lg font-semibold mb-3">Textarea</h3>
            <textarea
              class="textarea textarea-bordered w-full"
              placeholder="Enter your message here..."
            ></textarea>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp card_section(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="bg-neutral text-neutral-content px-6 py-3 border-4 border-base-300">
        <h2 class="text-xl font-bold uppercase tracking-wide" style="font-family: 'Courier New', monospace;">
          Cards
        </h2>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <!-- Basic Card -->
        <div class="bg-base-100 border-4 border-base-300 shadow-lg">
          <div class="p-6">
            <h2 class="text-lg font-bold mb-2 uppercase" style="font-family: 'Courier New', monospace;">
              Basic Card
            </h2>
            <p class="text-sm">This is a simple card with title and description.</p>
          </div>
        </div>

        <!-- Card with Image -->
        <div class="bg-base-100 border-4 border-base-300 shadow-lg">
          <div class="bg-base-300 h-48 flex items-center justify-center border-b-4 border-base-300">
            <.icon name="hero-photo" class="w-24 h-24 text-base-content opacity-20" />
          </div>
          <div class="p-6">
            <h2 class="text-lg font-bold mb-2 uppercase" style="font-family: 'Courier New', monospace;">
              Card with Image
            </h2>
            <p class="text-sm mb-4">Cards can include images at the top.</p>
            <div class="flex justify-end">
              <button class="btn btn-primary btn-sm">View</button>
            </div>
          </div>
        </div>

        <!-- Card with Badge -->
        <div class="bg-base-100 border-4 border-base-300 shadow-lg">
          <div class="p-6">
            <div class="flex items-center gap-2 mb-2">
              <h2 class="text-lg font-bold uppercase" style="font-family: 'Courier New', monospace;">
                Card with Badge
              </h2>
              <div class="badge badge-secondary">NEW</div>
            </div>
            <p class="text-sm mb-4">This card includes a badge in the title.</p>
            <div class="flex justify-end gap-2">
              <div class="badge badge-outline">Tag 1</div>
              <div class="badge badge-outline">Tag 2</div>
            </div>
          </div>
        </div>

        <!-- Compact Card -->
        <div class="bg-primary text-primary-content border-4 border-primary shadow-lg">
          <div class="p-6">
            <h2 class="text-lg font-bold mb-2 uppercase" style="font-family: 'Courier New', monospace;">
              Primary Color Card
            </h2>
            <p class="text-sm">Cards can use different color schemes.</p>
          </div>
        </div>

        <!-- Card with Stats -->
        <div class="bg-base-100 border-4 border-base-300 shadow-lg">
          <div class="p-6">
            <h2 class="text-lg font-bold mb-4 uppercase" style="font-family: 'Courier New', monospace;">
              Statistics
            </h2>
            <div class="stats shadow border-2 border-base-300">
              <div class="stat place-items-center">
                <div class="stat-title">Downloads</div>
                <div class="stat-value">31K</div>
              </div>
            </div>
          </div>
        </div>

        <!-- Card with Actions -->
        <div class="bg-base-100 border-4 border-base-300 shadow-lg">
          <div class="p-6">
            <h2 class="text-lg font-bold mb-2 uppercase" style="font-family: 'Courier New', monospace;">
              Actions Card
            </h2>
            <p class="text-sm mb-4">Cards with multiple action buttons.</p>
            <div class="flex justify-end gap-2">
              <button class="btn btn-ghost btn-sm">Cancel</button>
              <button class="btn btn-primary btn-sm">Save</button>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp alert_section(assigns) do
    ~H"""
    <div class="bg-base-100 border-4 border-base-300 shadow-lg">
      <div class="border-b-4 border-base-300 bg-neutral text-neutral-content px-6 py-3">
        <h2 class="text-xl font-bold uppercase tracking-wide" style="font-family: 'Courier New', monospace;">
          Alerts & Notifications
        </h2>
      </div>
      <div class="p-6">

        <div class="space-y-4">
          <!-- Info Alert -->
          <div class="alert alert-info">
            <.icon name="hero-information-circle" class="w-6 h-6" />
            <span>Information: This is an informational message.</span>
          </div>

          <!-- Success Alert -->
          <div class="alert alert-success">
            <.icon name="hero-check-circle" class="w-6 h-6" />
            <span>Success: Your action was completed successfully!</span>
          </div>

          <!-- Warning Alert -->
          <div class="alert alert-warning">
            <.icon name="hero-exclamation-triangle" class="w-6 h-6" />
            <span>Warning: Please review this important information.</span>
          </div>

          <!-- Error Alert -->
          <div class="alert alert-error">
            <.icon name="hero-x-circle" class="w-6 h-6" />
            <span>Error: Something went wrong. Please try again.</span>
          </div>

          <!-- Alert with Actions -->
          <div class="alert">
            <.icon name="hero-bell" class="w-6 h-6" />
            <span>New notification received.</span>
            <div>
              <button class="btn btn-sm">Deny</button>
              <button class="btn btn-sm btn-primary">Accept</button>
            </div>
          </div>

          <!-- Badges -->
          <div>
            <h3 class="text-lg font-semibold mb-3">Badges</h3>
            <div class="flex flex-wrap gap-2">
              <div class="badge">Default</div>
              <div class="badge badge-neutral">Neutral</div>
              <div class="badge badge-primary">Primary</div>
              <div class="badge badge-secondary">Secondary</div>
              <div class="badge badge-accent">Accent</div>
              <div class="badge badge-ghost">Ghost</div>
              <div class="badge badge-info">Info</div>
              <div class="badge badge-success">Success</div>
              <div class="badge badge-warning">Warning</div>
              <div class="badge badge-error">Error</div>
            </div>
          </div>

          <!-- Progress Bars -->
          <div>
            <h3 class="text-lg font-semibold mb-3">Progress Bars</h3>
            <div class="space-y-2">
              <progress class="progress w-full" value="0" max="100"></progress>
              <progress class="progress progress-primary w-full" value="25" max="100"></progress>
              <progress class="progress progress-secondary w-full" value="50" max="100"></progress>
              <progress class="progress progress-accent w-full" value="75" max="100"></progress>
              <progress class="progress progress-success w-full" value="100" max="100"></progress>
            </div>
          </div>

          <!-- Radial Progress -->
          <div>
            <h3 class="text-lg font-semibold mb-3">Radial Progress</h3>
            <div class="flex flex-wrap gap-4">
              <div class="radial-progress" style="--value:70;" role="progressbar">70%</div>
              <div
                class="radial-progress text-primary"
                style="--value:80;"
                role="progressbar"
              >
                80%
              </div>
              <div
                class="radial-progress text-secondary"
                style="--value:90;"
                role="progressbar"
              >
                90%
              </div>
              <div class="radial-progress text-accent" style="--value:100;" role="progressbar">
                100%
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp modal_section(assigns) do
    ~H"""
    <div class="bg-base-100 border-4 border-base-300 shadow-lg">
      <div class="border-b-4 border-base-300 bg-neutral text-neutral-content px-6 py-3">
        <h2 class="text-xl font-bold uppercase tracking-wide" style="font-family: 'Courier New', monospace;">
          Modals, Drawers & More
        </h2>
      </div>
      <div class="p-6">

        <div class="space-y-6">
          <!-- Modal Demo -->
          <div>
            <h3 class="text-lg font-semibold mb-3">Modal</h3>
            <button class="btn btn-primary" phx-click="open_modal">Open Modal</button>
            <p class="text-sm text-base-content/70 mt-2">
              Click to open a modal dialog
            </p>
          </div>

          <!-- Drawer Demo -->
          <div>
            <h3 class="text-lg font-semibold mb-3">Drawer</h3>
            <button class="btn btn-secondary" phx-click="toggle_drawer">Toggle Drawer</button>
            <p class="text-sm text-base-content/70 mt-2">
              Click to open a side drawer
            </p>
          </div>

          <!-- Loading Spinner -->
          <div>
            <h3 class="text-lg font-semibold mb-3">Loading Spinner</h3>
            <button class="btn btn-accent" phx-click="simulate_loading">
              <%= if @loading do %>
                <span class="loading loading-spinner"></span>
                Loading...
              <% else %>
                Simulate Loading
              <% end %>
            </button>
          </div>

          <!-- Toast Notification -->
          <div>
            <h3 class="text-lg font-semibold mb-3">Toast Notification</h3>
            <button class="btn btn-success" phx-click="show_toast">Show Toast</button>
            <p class="text-sm text-base-content/70 mt-2">
              Click to show a toast notification
            </p>
          </div>

          <!-- Loading Variants -->
          <div>
            <h3 class="text-lg font-semibold mb-3">Loading Variants</h3>
            <div class="flex flex-wrap gap-4 items-center">
              <span class="loading loading-spinner loading-xs"></span>
              <span class="loading loading-spinner loading-sm"></span>
              <span class="loading loading-spinner loading-md"></span>
              <span class="loading loading-spinner loading-lg"></span>
              <span class="loading loading-dots loading-lg"></span>
              <span class="loading loading-ring loading-lg"></span>
              <span class="loading loading-ball loading-lg"></span>
            </div>
          </div>

          <!-- Breadcrumbs -->
          <div>
            <h3 class="text-lg font-semibold mb-3">Breadcrumbs</h3>
            <div class="breadcrumbs text-sm">
              <ul>
                <li><a>Home</a></li>
                <li><a>Documents</a></li>
                <li>Current Page</li>
              </ul>
            </div>
          </div>

          <!-- Menu -->
          <div>
            <h3 class="text-lg font-semibold mb-3">Menu</h3>
            <ul class="menu bg-base-200 w-56 rounded-box">
              <li><a>Item 1</a></li>
              <li><a>Item 2</a></li>
              <li>
                <details open>
                  <summary>Parent</summary>
                  <ul>
                    <li><a>Submenu 1</a></li>
                    <li><a>Submenu 2</a></li>
                  </ul>
                </details>
              </li>
              <li><a>Item 3</a></li>
            </ul>
          </div>

          <!-- Stats -->
          <div>
            <h3 class="text-lg font-semibold mb-3">Stats</h3>
            <div class="stats shadow">
              <div class="stat">
                <div class="stat-figure text-primary">
                  <.icon name="hero-user-group" class="w-8 h-8" />
                </div>
                <div class="stat-title">Total Users</div>
                <div class="stat-value text-primary">25.6K</div>
                <div class="stat-desc">21% more than last month</div>
              </div>

              <div class="stat">
                <div class="stat-figure text-secondary">
                  <.icon name="hero-chart-bar" class="w-8 h-8" />
                </div>
                <div class="stat-title">Page Views</div>
                <div class="stat-value text-secondary">2.6M</div>
                <div class="stat-desc">↗︎ 400 (22%)</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
