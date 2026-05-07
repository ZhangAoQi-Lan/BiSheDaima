package com.printquote.backend.service;

public interface MailService {
    /**
     * 发送简单文本邮件
     * @param to 接收人
     * @param subject 标题
     * @param content 内容
     */
    void sendSimpleMail(String to, String subject, String content);
}
