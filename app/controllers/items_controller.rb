class ItemsController < ApplicationController

	before_action :authenticate_user!

  ensure_authorization_performed

  authorize_actions_for Item

  def index
    @event = Event.find params[:event_id]
    authorize_action_for @event
  	@items = @event.items.in(payer_id: current_user.id).order_by(:value_date => 'desc')
  end

  def new
    event = Event.find params[:event_id]
    @item = event.items.build(payer_id: current_user.id, value_date: event.from_date, event: event)
    authorize_action_for @item, event
  end

  def create
    @item = Item.new(item_params)
    @item.event_id = params[:event_id]
    authorize_action_for @item, @item.event
    (render :new and return) if invalid? @item
    @item.save
    EventMailer.item_created_message(@item).deliver_now!
    flash[:alert] = "Exchange rate updated to #{@item.exchange_rate}." if @item.rate_changed?
    redirect_to item_path(@item), :notice => "Item created."
  end

  def edit
    @item = Item.find params[:id]
    authorize_action_for @item
  end

  def update
    @item = Item.find params[:id]
    @item.update_attributes item_params
    authorize_action_for @item
    (render :edit and return) if invalid? @item
    @item.save
    EventMailer.item_modified_message(@item).deliver_now!
    flash[:alert] = "Exchange rate updated to #{@item.exchange_rate}." if @item.rate_changed?
    redirect_to item_path(@item), :notice => "Item updated."
  end

  def destroy
    item = Item.find(params[:id])
    event = item.event
    item.destroy if authorize_action_for item
    EventMailer.item_deleted_message(item).deliver_now!
    redirect_to event_items_path(event_id: event.id), :notice => "Item deleted."
  end

  def show
    @item = Item.find params[:id]
    authorize_action_for @item, @item.event
  end

  private

  def invalid? item
    ret = item.invalid?
    if ret then
      flash[:alert] = "Exchange rate updated to #{@item.exchange_rate}." if item.rate_changed?
      flash[:notice] = "Item is invalid. Please correct."
    end
    return ret
  end

  def item_params
    params.require(:item).permit(:name, :value_date, :description, :payer_id, :exchange_rate, 
      :base_amount, :base_currency, :foreign_amount, :foreign_currency, :event_id, :beneficiary_ids => [])
  end

end
