using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimationController : MonoBehaviour
{
    public Animator m_Animator;

    private void Awake()
    {
    }
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
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
        if (_isAiming) m_Animator.SetLayerWeight(1, 1);
        else m_Animator.SetLayerWeight(1, 0);
    }



}
