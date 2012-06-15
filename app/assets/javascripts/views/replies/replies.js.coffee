class Tutoriapps.Views.Replies extends Backbone.View
  className: 'replies'
  template: SMT['replies/replies']
  show: 'last_replies'

  initialize: =>
    @collection.on('reset', @render)
    @collection.on('add', @appendReply)

  events:
    'click .reply_link': 'showReplyForm'
    'submit form.new_reply': 'createReply'

  render: =>
    translations =
      t_reply: I18n.t('helpers.reply')
      t_see_all: I18n.t('helpers.comments.see_all')
      t_write_comment: I18n.t('helpers.comments.write')
    @$el.html(@template(translations))

    if @collection.length <= 0
      @$('form').hide()
    if @collection.length <= 2
      @$('.see_all').remove()

    if @show == 'last_replies'
      $(@collection.last(2)).each( (index, reply) => @appendReply(reply) )
    else if @show == 'all'
      @collection.each(@appendReply)
    this

  appendReply: (reply) =>
    view = new Tutoriapps.Views.Reply(model: reply)
    @$el.append(view.render().el)

  showReplyForm: (evt)=>
    evt.preventDefault()
    @$('form').show()

  createReply: (evt) =>
    evt.preventDefault()
    enabled = !$(evt.target).find('input[type="submit"]').hasClass('disabled')
    if(enabled)
      data = Backbone.Syphon.serialize(evt.target)
      @collection.create data,
      wait: true
      success: => 
        evt.target.reset()