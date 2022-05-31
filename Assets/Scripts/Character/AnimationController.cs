using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimationController : MonoBehaviour
{
    public Animator m_Animator;

    public void AnimationGround(bool _isGrounded)
    {
        m_Animator.SetBool("Grounded", _isGrounded);
    }

    public void AnimationJump(bool _isJumped)
    {
        m_Animator.SetBool("Jumped", _isJumped);
    }

    public void AnimationMovement(float _posX, float _posY)
    {
        m_Animator.SetFloat("PosX", _posX);
        m_Animator.SetFloat("PosY", _posY);
    }

    public void AnimationAiming(bool _isAiming)
    {
        if (_isAiming)
        {
            m_Animator.SetLayerWeight(1, 1);
            m_Animator.SetLayerWeight(2, 1);
        }
        else
        {
            m_Animator.SetLayerWeight(1, 0);
            m_Animator.SetLayerWeight(2, 0);
        }
    }

    public void AnimationAimAngle(float _angle)
    {
        m_Animator.SetFloat("AimX", _angle);
    }

    public void AnimationShootShort()
    {
        m_Animator.SetTrigger("shootShort");
        m_Animator.SetLayerWeight(1, 0.5f);
        m_Animator.SetLayerWeight(2, 1);
    }

    public void AnimationShootLong()
    {
        m_Animator.SetTrigger("shootLong");
        m_Animator.SetLayerWeight(1, 0.5f);
        m_Animator.SetLayerWeight(2, 1);
    }

}
