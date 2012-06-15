#coding: utf-8

Dado /^que se ha creado 1 post en el grupo "(.*?)"$/ do |group_name|
  @group = Group.find_by_name(group_name)
  FactoryGirl.create(:post, :group => @group)
end

Dado /^que el post no ha recibido comentarios$/ do
  @post = @group.posts.first
  @post.replies.count.should eq(0)
end

Dado /^que el post ha recibido 1 comentario$/ do
  @post = @group.posts.first
  @reply = FactoryGirl.create(:reply, :post => @post)
  @post.replies.count.should eq(1)
end

Dado /^que el post ha recibido (\d+) comentarios$/ do |n|
  @post = @group.posts.first
  n.to_i.times { FactoryGirl.create(:reply, :post => @post) }
  @post.replies.count.should eq(n.to_i)
end

Cuando /^el post aparezca en el muro$/ do
  within ".content_panel" do
    page.click_link @post.group.name
    page.should have_content(@post.text)
  end
end

Cuando /^intente agregar el primer comentario$/ do
  step 'el post aparezca en el muro'
  within find(:xpath, ".//*[contains(text(), '#{@post.text}')]").find(:xpath,".//ancestor::*[contains(@class, 'post')]") do
    page.click_link(I18n.t('helpers.reply'))
  end
  step 'intente agregar un comentario'
end

Cuando /^intente agregar un comentario$/ do
  step 'el post aparezca en el muro'
  @reply_attrs = attributes_for(:reply)
  within find(:xpath, ".//*[contains(text(), '#{@post.text}')]").find(:xpath,".//ancestor::*[contains(@class, 'post')]") do
    page.fill_in "text", :with => @reply_attrs[:text]
    page.find('.btn-primary').click
  end
end


Entonces /^se podrá observar que aún no tiene comentarios$/ do
  within find(:xpath, ".//*[contains(text(), '#{@post.text}')]").find(:xpath,".//ancestor::*[contains(@class, 'post')]") do
    page.should_not have_css('.replies .reply')
  end
end

Entonces /^se podrá leer el comentario$/ do
  within find(:xpath, ".//*[contains(text(), '#{@post.text}')]").find(:xpath,".//ancestor::*[contains(@class, 'post')]") do
    page.should have_content(@reply.text)
  end
end

Entonces /^se podrán leer los últimos (\d+) comentarios$/ do |n|
  last_two = @post.replies.order('replies.created_at DESC').limit(2)
  within find(:xpath, ".//*[contains(text(), '#{@post.text}')]").find(:xpath,".//ancestor::*[contains(@class, 'post')]") do
    for reply in last_two
      page.should have_content(reply.text)
    end
  end
end

Entonces /^aparecerá la opción de ver todos los comentarios$/ do
  within find(:xpath, ".//*[contains(text(), '#{@post.text}')]").find(:xpath,".//ancestor::*[contains(@class, 'post')]") do
    page.should have_content(I18n.t('helpers.comments.see_all'))
  end
end

Entonces /^no aparecerá la opción de ver todos los comentarios$/ do
  within find(:xpath, ".//*[contains(text(), '#{@post.text}')]").find(:xpath,".//ancestor::*[contains(@class, 'post')]") do
    page.should_not have_content(I18n.t('helpers.comments.see_all'))
  end
end

Entonces /^el comentario quedará publicado$/ do
  within find(:xpath, ".//*[contains(text(), '#{@post.text}')]").find(:xpath,".//ancestor::*[contains(@class, 'post')]") do
    page.should have_content(@reply_attrs[:text])
  end
end

=begin
Cuando /^intente responder un post$/ do
  @reply_attrs = attributes_for(:reply)
  within '.post:first' do
    page.click_link(I18n.t('helpers.reply'))
  end
  within '#replyModal' do
    page.fill_in "text", :with => @reply_attrs[:text]
    page.find('.btn-primary').click
  end
end

Cuando /^intente responder con un mensaje en blanco$/ do
  @reply_attrs = attributes_for(:reply)
  within '.post:first' do
    page.click_link(I18n.t('helpers.reply'))
  end
  within '#replyModal' do
    page.find('.btn-primary').click
  end
end

Entonces /^la respuesta será enviada$/ do
  page.should have_content(I18n.t('helpers.messages.reply_sent'))
end

Entonces /^no podrá enviar la respuesta$/ do
  page.should_not have_content(I18n.t('helpers.messages.reply_sent'))
  find('#replyModal')
end
=end