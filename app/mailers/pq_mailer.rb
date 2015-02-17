class PqMailer < PQBaseMailer
  default from: Settings.mail_from

  def commission_email(template_params)
  	@template_params = template_params

    mail(to: @template_params[:email], subject: "You have been allocated PQ #{@template_params[:uin]}")
  end

  def notify_dd_email(template_params)
    @template_params = template_params
    mail(to: @template_params[:email], subject: "#{@template_params[:ao_name]} has been allocated PQ #{@template_params[:uin]}")
  end

  def acceptance_email(pq, ao, urgent = false)
    cc_list = [
      dd_email(ao),
      mp_email(pq),
      policy_mp_email(pq),
      press_email(ao)
    ] + 
    mp_office_emails(pq, 'Simon Hughes (MP)') + 
    action_list_emails +
    finance_users_emails(pq)

    @template_params = build_primary_hash(pq, ao).merge({
      cc_list: cc_list.reject(&:blank?).join(';')
    })
        
    subject = if urgent
      "URGENT : please send your draft response for PQ #{@template_params[:uin]}"
    else
      "You have accepted PQ #{@template_params[:uin]}"
    end

    mail(to: @template_params[:email], subject: subject)
  end

  def acceptance_reminder_email(template_params)
    @template_params = template_params
    mail(to: @template_params[:email], subject: "URGENT: you need to accept or reject PQ #{@template_params[:uin]}")
  end

  def watchlist_email(template_params)
    @template_params = template_params
    date = Date.today.to_s(:date)
    @template_params[:date] = date
    mail(to: @template_params[:email], cc: @template_params[:cc], subject: 'PQs allocated today')
  end

  def import_fail_email(params)
    @params = params
    mail(to: Settings.mail_tech_support, subject: 'API import failed')
  end

private

  def build_primary_hash(pq, ao)
    {
      ao_name:              ao.name,
      email:                ao.emails,
      uin:                  pq.uin,
      question:             pq.question,
      mpname:               mp_name(pq),
      mpemail:              mp_email(pq),
      policy_mpname:        policy_mp_name(pq),
      policy_mpemail:       policy_mp_email(pq),
      press_email:          press_email(ao),
      member_name:          pq.member_name,
      house_name:           pq.house_name,
      internal_deadline:    internal_deadline(pq),
      date_to_parliament:   pq.date_for_answer.try(:to_s, :date),
      finance_users_emails: finance_users_emails(pq).join(';'),
    }
  end

  def mp_office_emails(pq, mp_name)
    if pq.minister && pq.minister.name == mp_name
      [
        'Christopher.Beal@justice.gsi.gov.uk',
        'Nicola.Calderhead@justice.gsi.gov.uk',
        'thomas.murphy@JUSTICE.gsi.gov.uk'
      ]
    else
      []
    end
  end

  def action_list_emails
    ActionlistMember.where('deleted = false').map{ |a| a.email }
  end

  def finance_users_emails(pq)
    if pq.finance_interest 
      User.finance.where('email IS NOT NULL').map(&:email)
    else
      []
    end
  end

  def dd_email(ao)
    ao.deputy_director && ao.deputy_director.email
  end

  def mp_name(pq)
    pq.minister && pq.minister.name
  end

  def mp_email(pq)
    pq.minister && pq.minister.email
  end

  def policy_mp_name(pq)
    pq.policy_minister && pq.policy_minister.name
  end

  def policy_mp_email(pq)
    pq.policy_minister && pq.policy_minister.email
  end

  def press_email(ao)
    ao.press_desk && ao.press_desk.email_output
  end

  def internal_deadline(pq)
    pq.internal_deadline ? "#{pq.internal_deadline.to_s(:date) } - 10am " : ''
  end
end
