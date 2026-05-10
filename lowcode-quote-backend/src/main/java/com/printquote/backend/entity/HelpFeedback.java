package com.printquote.backend.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("help_feedback")
public class HelpFeedback {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long articleId;

    private Long userId;

    private String feedbackType;

    private LocalDateTime createTime;
}
