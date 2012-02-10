class MessageController < ApplicationController

  def new
    @message = Message.new
  end

  def create
    @message = Message.new(params[:message])
    @addresses = params["addresses"]
    if @message.valid? && @addresses.length >0
      UserMailer.new_message(@addresses, @message).deliver
      redirect_to(:back, :notice => I18n.t('messagecontroller.messagesent'))
    else
      flash.now.alert = I18n.t('messagecontroller.fillinallfields')
      render :new
    end
  end

end
