using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Hit_Collider : MonoBehaviour
{
    public enum THitColliderType
    {
        BODY = 0,
        HEAD
    }
    public THitColliderType m_ColliderType;

    [SerializeField]
    private Sniper_Behaviour m_enemy;

    [SerializeField]
    private int m_BodyHitAmount;

    [SerializeField]
    private int m_HeadHitAmount;
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

    }
    public void Hit()
    {
        int l_HitAmount = m_HeadHitAmount;
        if (m_ColliderType == THitColliderType.BODY)
            l_HitAmount = m_BodyHitAmount;
        m_enemy.GetComponent<Enemy1HP>().Damage(l_HitAmount);
    }
}
