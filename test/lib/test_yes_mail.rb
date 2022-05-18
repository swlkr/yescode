require "minitest/autorun"

class TestYesMail < Minitest::Test
  def test_new_mail
    mail = YesMail.new.send(:new_mail, from: "from", to: "to", subject: "subject")

    assert_equal ["from"], mail.from
    assert_equal ["to"], mail.to
    assert_equal "subject", mail.subject
  end
end
