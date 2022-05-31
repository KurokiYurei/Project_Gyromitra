using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimationController : MonoBehaviour
{
    public Animator m_Animator;

    [SerializeField]
    private float m_WeightSmooth = 1.0f;

    static float t = 0.0f;
    static float s = 0.0f;

    public void AnimationAirTimer(float _airTimer)
    {
        m_Animator.SetFloat("airTimer", _airTimer);
    }

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
            s = 0;
            t += m_WeightSmooth * Time.deltaTime;
            m_Animator.SetLayerWeight(1, Mathf.Lerp(0f, 1f, t));
            m_Animator.SetLayerWeight(2, Mathf.Lerp(0f, 1f, t));
        }
        else
        {
            t = 0;
            s += m_WeightSmooth * Time.deltaTime;
            m_Animator.SetLayerWeight(1, Mathf.Lerp(1f, 0f, s));
            m_Animator.SetLayerWeight(2, Mathf.Lerp(1f, 0f, s));
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
